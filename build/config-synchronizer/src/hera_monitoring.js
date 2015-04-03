"use strict";

var fs = require('fs');
var Promise = require("nodegit-promise");
var request = require('request');

var KIBANA_DASHBOARDS_FOLDER = "kibana";
var GRAFANA_DASHBOARDS_FOLDER = "grafana";

var GRAFANA_INDEX = "grafana-dash";
var KIBANA_INDEX = "kibana-int";

module.exports = {

  dashboardController: function (dashboardsPath, elasticsearchUrl) {

    var getDashboardsDefinitions = function (path) {
      return new Promise(function (resolve, fail) {
        fs.readdir(path, function (err, files) {
          if (err) {
            fail(err);
          }
          new Promise(function (resolve, fail) {
            resolve(files.map(function (file) {
              var content = fs.readFileSync(path + "/" + file, "utf8", function (err) {
                if (err) {
                  fail(err);
                }
              });
              return JSON.parse(content);
            }));
          }).then(function (dashboardsDefinitions) {
            resolve(dashboardsDefinitions);
          });
        });
      });
    };

    var sendRequest = function (host, path, data) {
      console.log("POST " + host + "/" + path);
      return new Promise(function (resolve, fail) {
        request({
          url: host + "/" + path,
          method: "POST",
          json: true,
          body: data
        }, function (error, response) {
          if (error) {
            fail(error);
          } else {
            resolve(response.statusCode);
          }
        });
      });
    };

    var updateDashboard = function (dashboardDefinition, elasticsearchUrl, index) {
      return new Promise(function (resolve, fail) {
        var data = {
          user: "guest",
          group: "guest",
          title: dashboardDefinition.title,
          dashboard: JSON.stringify(dashboardDefinition)
        };
        var path = index + "/dashboard/" + encodeURIComponent(dashboardDefinition.title);
        console.log("Updating dashboard " + dashboardDefinition.title + " to " + index + "...");
        sendRequest(elasticsearchUrl, path, data).then(function (responseCode) {
          var result = {};
          result[dashboardDefinition.title] = responseCode === 201;
          resolve(result);
        }).catch(function (err) {
          fail(err);
        });
      });
    };

    return {

      updateGrafanaDashboards: function () {
        return new Promise(function (resolve, fail) {
          var grafanaDashboardsPath = dashboardsPath + "/" + GRAFANA_DASHBOARDS_FOLDER;
          getDashboardsDefinitions(grafanaDashboardsPath).then(function (dashboardsDefinitions) {
            var results = [];
            dashboardsDefinitions.forEach(function (dashboardDefinition) {
              updateDashboard(dashboardDefinition, elasticsearchUrl, GRAFANA_INDEX).then(function (result) {
                results.push(result);
                if (results.length === dashboardsDefinitions.length) {
                  resolve(results);
                }
              }).catch(function (err) {
                fail(err);
              });
            });
          }).catch(function (err) {
            fail(err);
          });
        });
      },

      updateKibanaDashboards: function () {
        return new Promise(function (resolve, fail) {
          var kibanaDashboardsPath = dashboardsPath + "/" + KIBANA_DASHBOARDS_FOLDER;
          getDashboardsDefinitions(kibanaDashboardsPath).then(function (dashboardsDefinitions) {
            var results = [];
            dashboardsDefinitions.forEach(function (dashboardDefinition) {
              updateDashboard(dashboardDefinition, elasticsearchUrl, KIBANA_INDEX).then(function (result) {
                results.push(result);
                if (results.length === dashboardsDefinitions.length) {
                  resolve(results);
                }
              }).catch(function (err) {
                fail(err);
              });
            });
          }).catch(function (err) {
            fail(err);
          });
        });
      },

      updateAllDashboards: function () {
        var globalSummary = {};
        var that = this;
        return new Promise(function (resolve, fail) {
          that.updateGrafanaDashboards().then(function (summary) {
            globalSummary.grafana = summary;
            return that.updateKibanaDashboards();
          }).then(function (summary) {
            globalSummary.kibana = summary;
            resolve(globalSummary);
          }).catch(function (err) {
            fail(err);
          });
        });
      }

    };

  }

};
