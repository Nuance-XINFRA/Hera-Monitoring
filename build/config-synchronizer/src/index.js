"use strict";

var express = require('express');
var git = require('./git_wrapper.js');
var hera = require('./hera_monitoring.js');

var PORT = 8080;
var LOCAL_REPOSITORY = "/tmp/dashboards";

var REMOTE_REPOSITORY = process.env.GIT_REPOSITORY;
var ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL;

var repository = git(LOCAL_REPOSITORY, REMOTE_REPOSITORY);
var dashboardController = hera.dashboardController(LOCAL_REPOSITORY + "/dashboards", ELASTICSEARCH_URL);

express().get('/dashboards/changed', function (req, res) {

  repository.fetchRemote().then(function (repositoryChanged) {
    res.json({ repositoryChanged: repositoryChanged });
  }).catch(function (err) {
    console.log(err);
    res.json(err);
  });

}).get('/dashboards/update', function (req, res) {

  repository.cloneRemote().then(function () {
    return dashboardController.updateAllDashboards();
  }).then(function (summary) {
    res.json(summary);
  }).catch(function (err) {
    console.log(err);
    res.json(err);
  });

}).listen(PORT);

console.log('Running on http://localhost:' + PORT);
