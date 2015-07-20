"use strict";

var express = require('express');
var git = require('./git_wrapper.js');
var hera = require('./hera_monitoring.js');
var fs = require('fs');

var PORT = 8080;
var LOCAL_REPOSITORY = "/tmp/dashboards";

var REMOTE_REPOSITORY = process.env.GIT_REPOSITORY;
var REMOTE_REPOSITORY_USERNAME = process.env.GIT_REPOSITORY_USERNAME;
var REMOTE_REPOSITORY_PASSWORD = process.env.GIT_REPOSITORY_PASSWORD;
var ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL;

var repository = git(LOCAL_REPOSITORY, REMOTE_REPOSITORY, REMOTE_REPOSITORY_USERNAME, REMOTE_REPOSITORY_PASSWORD);
var dashboardController = hera.dashboardController(LOCAL_REPOSITORY + "/dashboards", ELASTICSEARCH_URL);

function initDashboards() {
  return repository.cloneRemote().then(function () {
    return dashboardController.updateAllDashboards();
  });
}

express().get('/dashboards/changed', function (req, res) {

  repository.fetchRemote().then(function (repositoryChanged) {
    res.json({ repositoryChanged: repositoryChanged });
  }).catch(function (err) {
    console.log(err);
    res.json(err);
  });

}).get('/dashboards/update', function (req, res) {

  initDashboards().then(function (summary) {
    res.json(summary);
  }).catch(function (err) {
    console.log(err);
    res.json(err);
  });

}).listen(PORT);

setTimeout(function () {
  fs.exists(LOCAL_REPOSITORY, function (exists) {
    if (!exists) {
      initDashboards().then(function (summary) {
        console.log(summary);
      }).catch(function (err) {
        console.log(err);
      });
    }
  });
}, 30000);

console.log('Running on http://localhost:' + PORT);
