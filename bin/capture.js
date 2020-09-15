"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var puppeteer = require("puppeteer");
var pg = require("pg");
pg.defaults.ssl = false;
var processID = process.pid;
var postgresSQLURL = process.env.DATABASE_URL;
var hoursDelay = 2;
var date = +(process.argv[3] == undefined ? Date.now() - (1000 * 60 * 60 * hoursDelay) : process.argv[3]);
date = Math.floor(date / (1000 * 60 * 60)) * (1000 * 60 * 60);
var hour = new Date(date).getHours();
var day = new Date(date).getDay();
if (day == 0 || day == 6 || hour < 9 || hour >= 17) {
    console.log('Out of school hours: ' + new Date(date));
    process.exit(0);
}

function start() {
    return __awaiter(this, void 0, void 0, function () {
        var clientOptions, section, limit, offset, client, error_1, query, rows, error_2;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    clientOptions = {};
                    if (postgresSQLURL == undefined) {
                        clientOptions.user = 'postgres';
                        clientOptions.host = 'localhost';
                        clientOptions.database = 'postgres';
                        clientOptions.password = 'docker';
                        clientOptions.port = 54320;
                        clientOptions.ssl = false;
                    }
                    else {
                        clientOptions.connectionString = postgresSQLURL;
                    }
                    section = process.argv[2];
                    limit = 150;
                    offset = (parseInt(section) - 1) * limit;
                    console.log('Connecting to postgress using ' + JSON.stringify(clientOptions));
                    client = new pg.Client(clientOptions);
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 3, , 4]);
                    return [4 /*yield*/, client.connect()];
                case 2:
                    _a.sent();
                    return [3 /*break*/, 4];
                case 3:
                    error_1 = _a.sent();
                    console.log('Unable to connect to Postgress: (' + error_1 + ')');
                    process.exit(0);
                    return [3 /*break*/, 4];
                case 4:
                    console.log('Connected to postgresSQL');
                    query = 'SELECT * FROM locations WHERE category=\'SCHOOL\' ORDER BY id LIMIT ' + limit + ' OFFSET ' + offset;
                    _a.label = 5;
                case 5:
                    _a.trys.push([5, 8, , 9]);
                    return [4 /*yield*/, client.query(query)];
                case 6:
                    rows = _a.sent();
                    return [4 /*yield*/, processEscoles(rows.rows, client)];
                case 7:
                    _a.sent();
                    return [3 /*break*/, 9];
                case 8:
                    error_2 = _a.sent();
                    console.log('Query for schools failed: (' + error_2 + ')');
                    process.exit(0);
                    return [3 /*break*/, 9];
                case 9: return [2 /*return*/];
            }
        });
    });
}
function processEscoles(escoles, client) {
    return __awaiter(this, void 0, void 0, function () {
        var browser, page, i, _i, escoles_1, escola, availableRetries, elements, found, _a, elements_1, element, label, value, query, error_3, error_4;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    console.log('[' + processID + '] Processing ' + escoles.length + ' schools');
                    _b.label = 1;
                case 1:
                    _b.trys.push([1, 19, , 20]);
                    return [4 /*yield*/, puppeteer.launch({
                            userDataDir: '/tmp/user-data-dir',
                            headless: true,
                            args: ['--no-sandbox']
                        })];
                case 2:
                    browser = _b.sent();
                    return [4 /*yield*/, browser.newPage()];
                case 3:
                    page = _b.sent();
                    i = escoles.length;
                    _i = 0, escoles_1 = escoles;
                    _b.label = 4;
                case 4:
                    if (!(_i < escoles_1.length)) return [3 /*break*/, 17];
                    escola = escoles_1[_i];
                    console.log('[' + processID + '] ' + i + ' Escola ' + escola.name + ' (' + escola.latitude + ', ' + escola.longitude + ', ' + new Date(date) + ')');
                    availableRetries = 3;
                    _b.label = 5;
                case 5:
                    if (!true) return [3 /*break*/, 15];
                    _b.label = 6;
                case 6:
                    _b.trys.push([6, 13, , 14]);
                    console.log('https://aire-barcelona.lobelia.earth/ca/?lon=' + escola.longitude + '&lat=' + escola.latitude + '&time=' + date);
                    return [4 /*yield*/, page.goto('https://aire-barcelona.lobelia.earth/ca/?lon=' + escola.longitude + '&lat=' + escola.latitude + '&time=' + date, { "waitUntil": "networkidle2" })];
                case 7:
                    _b.sent();
                    return [4 /*yield*/, page.$$('text')];
                case 8:
                    elements = _b.sent();
                    found = false;
                    _a = 0, elements_1 = elements;
                    _b.label = 9;
                case 9:
                    if (!(_a < elements_1.length)) return [3 /*break*/, 12];
                    element = elements_1[_a];
                    return [4 /*yield*/, page.evaluate(function (el) { return el.innerHTML; }, element)];
                case 10:
                    label = _b.sent();
                    if (label.includes('/m')) {
                        value = label.split(' ')[0];
                        query = 'INSERT INTO logs (location_id, value, pollutant_id, registered_at, created_at, updated_at) VALUES (' + escola.id + ', ' + value + ', 1, to_timestamp(' + (date + (1000 * 60 * 60 * 2)) / 1000.0 + '), to_timestamp(' + Date.now() / 1000.0 + '), to_timestamp(' + Date.now() / 1000.0 + '))';
                        console.log(query);
                        console.log('Value: ' + value);
                        client.query(query);
                        found = true;
                        return [3 /*break*/, 12];
                    }
                    _b.label = 11;
                case 11:
                    _a++;
                    return [3 /*break*/, 9];
                case 12:
                    if (!found) {
                        console.log('NO2 value not found for school.');
                    }
                    return [3 /*break*/, 15];
                case 13:
                    error_3 = _b.sent();
                    console.log('Failed to fetch page ' + 'https://aire-barcelona.lobelia.earth/ca/?lon=' + escola.longitude + '&lat=' + escola.latitude + '&time=' + date);
                    if (availableRetries != 0) {
                        console.log('Will retry...');
                        availableRetries = availableRetries - 1;
                    }
                    else {
                        console.log('Giving up on ' + 'https://aire-barcelona.lobelia.earth/ca/?lon=' + escola.longitude + '&lat=' + escola.latitude + '&time=' + date);
                        return [3 /*break*/, 15];
                    }
                    return [3 /*break*/, 14];
                case 14: return [3 /*break*/, 5];
                case 15:
                    i = i - 1;
                    _b.label = 16;
                case 16:
                    _i++;
                    return [3 /*break*/, 4];
                case 17: return [4 /*yield*/, browser.close()];
                case 18:
                    _b.sent();
                    process.exit(0);
                    return [3 /*break*/, 20];
                case 19:
                    error_4 = _b.sent();
                    console.log('Error while processing schools: (' + error_4 + ')');
                    process.exit(0);
                    return [3 /*break*/, 20];
                case 20: return [2 /*return*/];
            }
        });
    });
}
start();
