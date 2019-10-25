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
var pg_1 = require("pg");
pg_1.defaults.ssl = true;
var results = [];
var processID = process.pid;
var postgresSQLURL = process.env.DATABASE_URL;

var hoursDelay = 5;
var date = Date.now() - (1000 * 60 * 60 * hoursDelay);
date = Math.floor(date/(1000 * 60 * 60)) * (1000 * 60 * 60)
var hour = new Date(date).getHours();
var day = new Date(date).getDay();

if(day == 0 || day == 6 || hour < 9 || hour >= 17) {
    console.log('Out of school hours: ' + new Date(date));
    process.exit(0);
}

function start() {
    return __awaiter(this, void 0, void 0, function () {
        var section, limit, offset, client, query, rows;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    if (postgresSQLURL == undefined) {
                        console.log('No postgresSQL url found in the environment variables');
                        process.exit(0);
                    }
                    section = process.argv[2];
                    limit = 150;
                    offset = (parseInt(section) - 1) * limit;
                    client = new pg_1.Client({ connectionString: postgresSQLURL });
                    return [4 /*yield*/, client.connect()];
                case 1:
                    _a.sent();
                    console.log('Connected to postgresSQL');
                    query = 'SELECT * FROM locations WHERE category=\'SCHOOL\' ORDER BY id LIMIT ' + limit + ' OFFSET ' + offset;
                    console.log(query);
                    return [4 /*yield*/, client.query(query)];
                case 2:
                    rows = _a.sent();
                    return [4 /*yield*/, processEscoles(rows.rows, client)];
                case 3:
                    _a.sent();
                    return [2 /*return*/];
            }
        });
    });
}
function processEscoles(escoles, client) {
    return __awaiter(this, void 0, void 0, function () {
        var browser, page, i, _i, escoles_1, escola, elements, _a, elements_1, element, label, value, query;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    console.log('[' + processID + '] Processing ' + escoles.length + ' schools');
                    return [4 /*yield*/, puppeteer.launch({
                            userDataDir: '/tmp/user-data-dir',
                            headless: true,
                            args: ['--no-sandbox']
                        })];
                case 1:
                    browser = _b.sent();
                    return [4 /*yield*/, browser.newPage()];
                case 2:
                    page = _b.sent();
                    i = escoles.length;
                    _i = 0, escoles_1 = escoles;
                    _b.label = 3;
                case 3:
                    if (!(_i < escoles_1.length)) return [3 /*break*/, 11];
                    escola = escoles_1[_i];
                    console.log('[' + processID + '] ' + i + ' Escola ' + escola.name + ' (' + escola.latitude + ', ' + escola.longitude + ', ' + new Date(date) + ')');
                    return [4 /*yield*/, page.goto('https://aire-barcelona.lobelia.earth/ca/?lon=' + escola.longitude + '&lat=' + escola.latitude + '&time=' + date, { "waitUntil": "networkidle2" })];
                case 4:
                    _b.sent();
                    return [4 /*yield*/, page.$$('text')];
                case 5:
                    elements = _b.sent();
                    _a = 0, elements_1 = elements;
                    _b.label = 6;
                case 6:
                    if (!(_a < elements_1.length)) return [3 /*break*/, 9];
                    element = elements_1[_a];
                    return [4 /*yield*/, page.evaluate(function (el) { return el.innerHTML; }, element)];
                case 7:
                    label = _b.sent();
                    if (label.includes('/m')) {
                        value = label.split(' ')[0];
                        query = 'INSERT INTO logs (location_id, value, pollutant_id, registered_at, created_at, updated_at) VALUES (' + escola.id + ', ' + value + ', 1, to_timestamp(' + (date + (1000 * 60 * 60 * 2)) / 1000.0 + '), to_timestamp(' + Date.now() / 1000.0 + '), to_timestamp(' + Date.now() / 1000.0 + '))';          client.query(query);
                        return [3 /*break*/, 9];
                    }
                    _b.label = 8;
                case 8:
                    _a++;
                    return [3 /*break*/, 6];
                case 9:
                    i = i - 1;
                    _b.label = 10;
                case 10:
                    _i++;
                    return [3 /*break*/, 3];
                case 11: return [4 /*yield*/, browser.close()];
                case 12:
                    _b.sent();
                    process.exit(0);
                    return [2 /*return*/];
            }
        });
    });
}
start();
