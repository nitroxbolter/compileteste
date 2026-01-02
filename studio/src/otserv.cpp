// Copyright 2022 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "server.h"

#include "game.h"

#include "iomarket.h"

#include "configmanager.h"
#include "consolemanager.h"
#include "scriptmanager.h"
#include "rsa.h"
#include "protocolold.h"
#include "protocollogin.h"
#include "protocolstatus.h"
#include "databasemanager.h"
#include "scheduler.h"
#include "databasetasks.h"
#include "script.h"
#include "itemattributes.h"
#include <iomanip>
#include <sstream>
#include <fmt/core.h>
#include <fmt/color.h>
#include <algorithm>
#include <cctype>
#include <fstream>
#if __has_include("gitmetadata.h")
	#include "gitmetadata.h"
#endif

DatabaseTasks g_databaseTasks;
Dispatcher g_dispatcher;
Scheduler g_scheduler;

Game g_game;
ConfigManager g_config;
Monsters g_monsters;
Vocations g_vocations;
extern Scripts* g_scripts;
RSA g_RSA;

std::mutex g_loaderLock;
std::condition_variable g_loaderSignal;
std::unique_lock<std::mutex> g_loaderUniqueLock(g_loaderLock);

std::string getHorizontalLine()
{
	std::ostringstream s;
	s << std::setw(80) << std::setfill('-') << "" << std::endl << std::setfill(' ');
	return s.str();
}

void startupErrorMessage(const std::string& errorStr)
{
	console::print(CONSOLEMESSAGE_TYPE_ERROR, "> ERROR: " + errorStr);
	g_loaderSignal.notify_all();
}

void mainLoader(int argc, char* argv[], ServiceManager* servicer);
bool argumentsHandler(const StringVector& args);

[[noreturn]] void badAllocationHandler()
{
	// Use functions that only use stack allocation
	puts("Allocation failed, server out of memory.\nDecrease the size of your map or compile in 64 bits mode.\n");
	getchar();
	exit(-1);
}

int main(int argc, char* argv[])
{
	StringVector args = StringVector(argv, argv + argc);
	if(argc > 1 && !argumentsHandler(args)) {
		return 0;
	}

	// Setup bad allocation handler
	std::set_new_handler(badAllocationHandler);

	ServiceManager serviceManager;

	g_dispatcher.start();
	g_scheduler.start();

	g_dispatcher.addTask(createTask(std::bind(mainLoader, argc, argv, &serviceManager)));

	g_loaderSignal.wait(g_loaderUniqueLock);

	if (serviceManager.is_running()) {
		console::printResultText(fmt::format("{} Server Online!", g_config.getString(ConfigManager::SERVER_NAME)));
		console::print(CONSOLEMESSAGE_TYPE_STARTUP, "");
		serviceManager.run();
	} else {
		console::print(CONSOLEMESSAGE_TYPE_ERROR, ">> No services running. The server is NOT online.");
		g_scheduler.shutdown();
		g_databaseTasks.shutdown();
		g_dispatcher.shutdown();
	}

	g_scheduler.join();
	g_databaseTasks.join();
	g_dispatcher.join();
	return 0;
}

void printServerVersion()
{
	std::ostringstream startupMsg;
	std::string hrLine = getHorizontalLine();
	startupMsg << hrLine;

#if defined(GIT_RETRIEVED_STATE) && GIT_RETRIEVED_STATE
	std::cout << STATUS_SERVER_NAME << " - Version " << GIT_DESCRIBE << std::endl;
	std::cout << "Git SHA1 " << GIT_SHORT_SHA1  << " dated " << GIT_COMMIT_DATE_ISO8601 << std::endl;
	#if GIT_IS_DIRTY
	std::cout << "*** DIRTY - NOT OFFICIAL RELEASE ***" << std::endl;
	#endif
#else
	startupMsg << console::setColor(console::header, fmt::format("- {:s} - Version {:s}", STATUS_SERVER_NAME, STATUS_SERVER_VERSION)) << std::endl;
#endif
	startupMsg << std::endl;

	startupMsg << console::setColor(console::header, fmt::format("- Compiled with {:s}", BOOST_COMPILER)) << std::endl;

#if defined(__amd64__) || defined(_M_X64)
	std::string platform = "x64";
#elif defined(__i386__) || defined(_M_IX86) || defined(_X86_)
	std::string platform = "x86";
#elif defined(__arm__)
	std::string platform = "ARM";
#else
	std::string platform = "other";
#endif

	startupMsg << console::setColor(console::header, fmt::format("- Compiled on {:s} {:s} for platform {:s}", __DATE__, __TIME__, platform)) << std::endl;

#if defined(LUAJIT_VERSION)
	startupMsg << console::setColor(console::header, fmt::format("- Linked with {:s} for Lua support", LUAJIT_VERSION)) << std::endl;
#else
	startupMsg << console::setColor(console::header, fmt::format("- Linked with {:s} for Lua support", LUA_RELEASE)) << std::endl;
#endif

    startupMsg << hrLine;
    startupMsg << "- " << "A server developed by " << console::setColor(console::developers, "Edu Gaier") << std::endl;
    startupMsg << "- " << "Based on TFS 1.4.2 framework, protocol 1098" << std::endl;
    startupMsg << hrLine;
    std::string location = "printServerVersion";
    console::print(CONSOLEMESSAGE_TYPE_STARTUP, startupMsg.str(), true, location);

}

bool caseInsensitiveEqual(const std::string& a, const std::string& b)
{
	if (a.size() != b.size()) {
		return false;
	}
	return std::equal(a.begin(), a.end(), b.begin(),
		[](char a, char b) { return std::tolower(a) == std::tolower(b); });
}

void mainLoader(int, char*[], ServiceManager* services)
{
	//dispatcher thread
	g_game.setGameState(GAME_STATE_STARTUP);

	int64_t starttime = OTSYS_TIME();
	srand(static_cast<unsigned int>(OTSYS_TIME()));
#ifdef _WIN32
	SetConsoleTitle(STATUS_SERVER_NAME);
#endif

	printServerVersion();

	// check if config.lua or config.lua.dist exist
	const std::string& configFile = g_config.getString(ConfigManager::CONFIG_FILE);
	const std::string& distFile = configFile + ".dist";
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading " + configFile + " ... ", false);

	// Load config.lua or generate one from config.lua.dist file
	std::ifstream c_test(("./" + configFile).c_str());

	if (!c_test.is_open()) {
		std::ifstream config_lua_dist(("./" + distFile).c_str());
		console::printResult(CONSOLE_LOADING_PENDING);
		console::print(CONSOLEMESSAGE_TYPE_INFO, "Copying " + distFile + " to " + configFile + " ... ", false);

		if (config_lua_dist.is_open()) {
			std::ofstream config_lua(configFile.c_str());
			config_lua << config_lua_dist.rdbuf();
			config_lua.close();
			config_lua_dist.close();
			console::printResult(CONSOLE_LOADING_OK);
			console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading " + configFile + " ... ", false);
		} else {
			console::printResult(CONSOLE_LOADING_ERROR);
			console::reportFileError("", distFile);
			return;
		}
	}

	// read global config
	std::cout << ">> Loading config" << std::endl;
	if (!g_config.load()) {
		console::reportFileError("", configFile);
		return;
	}
	console::printResult(CONSOLE_LOADING_OK);

#ifdef _WIN32
	const std::string& defaultPriority = g_config.getString(ConfigManager::DEFAULT_PRIORITY);
	if (strcasecmp(defaultPriority.c_str(), "high") == 0) {
		SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
	} else if (strcasecmp(defaultPriority.c_str(), "above-normal") == 0) {
		SetPriorityClass(GetCurrentProcess(), ABOVE_NORMAL_PRIORITY_CLASS);
	}
#endif

	//set RSA key
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading RSA key ...", false);
	try {
		g_RSA.loadPEM("key.pem");
	} catch(const std::exception& e) {
		startupErrorMessage(e.what());
		return;
	}

	// Connect to the database
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Establishing database connection...", false);

	if (!Database::getInstance().connect()) {
		startupErrorMessage("Failed to connect to database.");
		return;
	}

	console::printResultText("MySQL " + std::string(Database::getClientVersion()));

	// run database manager
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Running database manager", false);

	if (!DatabaseManager::isDatabaseSetup()) {
		startupErrorMessage("The database you have specified in config.lua is empty, please import the schema.sql to your database.");
		return;
	}
	g_databaseTasks.start();

	DatabaseManager::updateDatabase();

	if (g_config.getBoolean(ConfigManager::OPTIMIZE_DATABASE)) {
		console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Optimizing database tables ...", false);
		if (!DatabaseManager::optimizeTables()) {
			console::printResult(CONSOLE_LOADING_OK);
			console::print(CONSOLEMESSAGE_TYPE_INFO, "No tables were optimized.");
		} else {
			console::printResult(CONSOLE_LOADING_OK);
		}
	}

	//load vocations
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading vocations ...", false);
	if (!g_vocations.loadFromXml()) {
		startupErrorMessage("Unable to load vocations!");
		return;
	}

	// load item data
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading items ...", false);
	if (!Item::items.loadFromOtb("data/items/items.otb")) {
		startupErrorMessage("Unable to load items (OTB)!");
		return;
	}

	if (!Item::items.loadFromXml()) {
		startupErrorMessage("Unable to load items (XML)!");
		return;
	}

	// load lua scripts
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading script systems ...", false);
#if defined(LUAJIT_VERSION)
	console::printResultText(LUAJIT_VERSION);
#else
	console::printResultText(LUA_RELEASE);
#endif
	if (!ScriptingManager::getInstance().loadScriptSystems()) {
		startupErrorMessage("Failed to load script systems");
		return;
	}

	if (!g_scripts->loadScripts("scripts", false, false)) {
		startupErrorMessage("Failed to load lua scripts");
		return;
	}

	// Load lua monsters
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading monsters (xml + lua) ... ", false);
	if (!g_monsters.loadFromXml()) {
		startupErrorMessage("Unable to load monsters!");
		return;
	}

	if (!g_scripts->loadScripts("monster", false, false)) {
		startupErrorMessage("Failed to load lua monsters");
		return;
	}
	console::printResultText("monsters: " + std::to_string(g_monsters.monsters.size()));

	// Load quests
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading quests ...", false);
	// Quest loading is handled in game.cpp,
	console::printResult(CONSOLE_LOADING_OK);
	console::printResultText("Loaded 1 quests");

	// Load outfits
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading outfits ...", false);
	if (!Outfits::getInstance().loadFromXml()) {
		startupErrorMessage("Unable to load outfits!");
		return;
	}
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading Item Attributes ...", false);
	if (!ItemRarityAttributes::getInstance()->load()) {
		startupErrorMessage("Unable to load item attributes!");
		return;
	}

	// Check world type
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Checking world type ...", false);
	std::string worldType = asLowerCaseString(g_config.getString(ConfigManager::WORLD_TYPE));
	if (worldType == "pvp") {
		g_game.setWorldType(WORLD_TYPE_PVP);
	} else if (worldType == "no-pvp") {
		g_game.setWorldType(WORLD_TYPE_NO_PVP);
	} else if (worldType == "pvp-enforced") {
		g_game.setWorldType(WORLD_TYPE_PVP_ENFORCED);
	} else {
		console::printResult(CONSOLE_LOADING_ERROR);
		startupErrorMessage(fmt::format("Unknown world type: {}, valid world types are: pvp, no-pvp and pvp-enforced.", g_config.getString(ConfigManager::WORLD_TYPE)));
		return;
	}
	console::printResultText(asUpperCaseString(worldType));

	// load map
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading world map...");
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "");

	const std::string& worldName = g_config.getString(ConfigManager::MAP_NAME);
	console::printWorldInfo("Filename", worldName + ".otbm");

	if (!g_game.loadMainMap(worldName)) {
		startupErrorMessage("Failed to load map");
		return;
	}

	// Loading guilds
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loading guilds ...", false);
	// Check if there are guilds to load
	console::printResultText("All guilds have been loaded.");

	console::printWorldInfo("Towns", std::to_string(g_game.map.towns.getTowns().size()));
	console::printWorldInfo("Houses", std::to_string(g_game.map.houses.getHouses().size()));
	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "");
	console::printWorldInfo("Monsters", "0");
	console::printWorldInfo("NPCs", "0");
	console::printWorldInfo("Spawns", "0");

	g_game.setGameState(GAME_STATE_INIT);

	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "");
	//console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Binding ports ...");

	uint16_t loginPort = static_cast<uint16_t>(g_config.getNumber(ConfigManager::LOGIN_PORT));
	uint16_t gamePort = static_cast<uint16_t>(g_config.getNumber(ConfigManager::GAME_PORT));
	uint16_t statusPort = static_cast<uint16_t>(g_config.getNumber(ConfigManager::STATUS_PORT));

	// Game client protocols
	services->add<ProtocolGame>(static_cast<uint16_t>(g_config.getNumber(ConfigManager::GAME_PORT)));
	services->add<ProtocolLogin>(static_cast<uint16_t>(g_config.getNumber(ConfigManager::LOGIN_PORT)));

	// OT protocols
	services->add<ProtocolStatus>(static_cast<uint16_t>(g_config.getNumber(ConfigManager::STATUS_PORT)));

	// Legacy login protocol
	services->add<ProtocolOld>(static_cast<uint16_t>(g_config.getNumber(ConfigManager::LOGIN_PORT)));

	RentPeriod_t rentPeriod;
	std::string strRentPeriod = asLowerCaseString(g_config.getString(ConfigManager::HOUSE_RENT_PERIOD));

	if (strRentPeriod == "yearly") {
		rentPeriod = RENTPERIOD_YEARLY;
	} else if (strRentPeriod == "weekly") {
		rentPeriod = RENTPERIOD_WEEKLY;
	} else if (strRentPeriod == "monthly") {
		rentPeriod = RENTPERIOD_MONTHLY;
	} else if (strRentPeriod == "daily") {
		rentPeriod = RENTPERIOD_DAILY;
	} else {
		rentPeriod = RENTPERIOD_NEVER;
	}

	g_game.map.houses.payHouses(rentPeriod);

	IOMarket::checkExpiredOffers();
	IOMarket::getInstance().updateStatistics();

	console::print(CONSOLEMESSAGE_TYPE_STARTUP, "Loaded all modules, server starting up...", false);
	console::printResult(CONSOLE_LOADING_OK);

	console::printResultText(fmt::format("Server started in {:.3f} seconds.", (OTSYS_TIME() - starttime) / (1000.)), console::Color::purple);

#ifndef _WIN32
	if (getuid() == 0 || geteuid() == 0) {
		console::print(CONSOLEMESSAGE_TYPE_WARNING, "Running as root is discouraged, run as a normal user.", true);
	}
#endif

	g_game.start(services);
	g_game.setGameState(GAME_STATE_NORMAL);
	g_loaderSignal.notify_all();
}

bool argumentsHandler(const StringVector& args)
{
	for (const auto& arg : args) {
		if (arg == "--help") {
			std::clog << "Usage:\n"
			"\n"
			"\t--config=$1\t\tAlternate configuration file path.\n"
			"\t--ip=$1\t\t\tIP address of the server.\n"
			"\t\t\t\tShould be equal to the global IP.\n"
			"\t--login-port=$1\tPort for login server to listen on.\n"
			"\t--game-port=$1\tPort for game server to listen on.\n";
			return false;
		} else if (arg == "--version") {
			printServerVersion();
			return false;
		}

		StringVector tmp = explodeString(arg, "=");

		if (tmp[0] == "--config")
			g_config.setString(ConfigManager::CONFIG_FILE, tmp[1]);
		else if (tmp[0] == "--ip")
			g_config.setString(ConfigManager::IP, tmp[1]);
		else if (tmp[0] == "--login-port")
			g_config.setNumber(ConfigManager::LOGIN_PORT, std::stoi(tmp[1]));
		else if (tmp[0] == "--game-port")
			g_config.setNumber(ConfigManager::GAME_PORT, std::stoi(tmp[1]));
	}

	return true;
}
