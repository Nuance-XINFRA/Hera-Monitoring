"use strict";

var fs = require('fs');
var NodeGit = require("nodegit");
var Promise = require("nodegit-promise");
var rimraf = require("rimraf");
var Clone = NodeGit.Clone;
var Repository = NodeGit.Repository;
var Remote = NodeGit.Remote;
var Cred = NodeGit.Cred;

var DEFAULT_REMOTE_NAME = "origin";


module.exports = function (localPath, remotePath, remoteUser, remotePass) {

  var repository;

  var getRepository = function () {
    return new Promise(function (resolve, fail) {
      if (!repository) {
        Repository.open(localPath).then(function (repo) {
          repository = repo;
          resolve(repository);
        }).catch(function (err) {
          fail(err);
        });
      } else {
        resolve(repository);
      }
    });
  };

  var removeFolderIfExists = function (folder) {
    return new Promise(function (resolve, fail) {
      fs.exists(localPath, function (exists) {
        if (exists) {
          console.log(folder + " already exists. Removing...");
          rimraf(folder, function (err) {
            if (err) {
              fail(err);
            } else {
              resolve();
            }
          });
        } else {
          resolve();
        }
      });
    });
  };

  return {

    fetchRemote: function () {
      return new Promise(function (resolve, fail) {

        var headCommitId;

        getRepository().then(function (repository) {
          return NodeGit.Reference.nameToId(repository, "HEAD");
        }).then(function (head) {
          return repository.getCommit(head);
        }).then(function (commit) {
          headCommitId = commit.sha();
          console.log("Head is currently " + headCommitId);
          console.log("Pulling the remote repository...");
          return repository.fetchAll({
            credentials: function () {
              if (remoteUser && remotePass) {
                return NodeGit.Cred.userpassPlaintextNew(remoteUser,remotePass);
              } else {
                return NodeGit.Cred.defaultNew();
              }
            },
            certificateCheck: function () {
              return 1;
            }
          }, true);
        }).then(function () {
          return repository.getBranchCommit("origin/master");
        }).then(function (remoteCommit) {
          var remoteCommitId = remoteCommit.sha();
          console.log("Remote is " + remoteCommitId);
          resolve(remoteCommitId !== headCommitId);
        }).catch(function (err) {
          fail(err);
        });

      });
    },

    cloneRemote: function () {
      return new Promise(function (resolve, fail) {
        removeFolderIfExists(localPath).then(function () {
          console.log("Cloning remote repository...");
          var opts = {
            remoteCallbacks: {
              certificateCheck: function() {
                return 1;
              },
              credentials: function() {
                if (remoteUser && remotePass) {
                  return NodeGit.Cred.userpassPlaintextNew(remoteUser,remotePass);
                } else {
                  return NodeGit.Cred.defaultNew();
                }
              }
            }
          };
          return Clone.clone(remotePath, localPath, opts);
        }).then(function (repo) {
          repository = repo;
          console.log("Repository cloned.");
          resolve();
        }).catch(function (err) {
          fail(err);
        });
      });
    },

    mergeFetch: function () {
      return new Promise(function (resolve, fail) {
        getRepository().then(function (repository) {
          console.log("Merging fetch branch...");
          return repository.mergeBranches("master", DEFAULT_REMOTE_NAME + "/master");
        }).then(function () {
          resolve();
        }).catch(function (err) {
          fail(err);
        });
      });
    }

  };
};
