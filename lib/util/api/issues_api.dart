import 'dart:convert';
// import 'dart:io';

import 'package:bugheist/routes/routing.dart';
import 'package:bugheist/util/endpoints/issue_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/issuedata_model.dart';
import '../../models/issue_model.dart';

class IssueApiClient {
  IssueApiClient._();

  static Future<IssueData?> getAllIssues(String paginatedUrl) async {
    http.Response? response;
    IssueData? issueData;
    List<Issue>? issueList;
    try {
      response = await http.get(Uri.parse(paginatedUrl));
      if (response.statusCode == 200) {
        issueList = [];
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        decodedResponse["results"].forEach((element) {
          issueList!.add(Issue.fromJson(element));
        });
        issueData = IssueData(
          count: decodedResponse["count"],
          nextQuery: decodedResponse["next"],
          previousQuery: decodedResponse["previous"],
          issueList: issueList,
        );
      }
    } catch (e) {
      print(e);
    }
    return issueData;
  }

  static Future<Issue?> getIssueById(int id) async {
    http.Response? response;
    Issue? issue;
    try {
      response = await http.get(Uri.parse(IssueEndPoints.issues + "$id/"));
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        issue = Issue.fromJson(decodedResponse);
      }
    } catch (e) {
      print(e);
    }
    return issue;
  }

  static Future<IssueData?> searchIssueByKeyWord(query) async {
    http.Response? response;
    IssueData? issueData;
    List<Issue>? issueList;
    try {
      String searchUrl = IssueEndPoints.issues + "?search=$query";
      response = await http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        issueList = [];
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        decodedResponse["results"].forEach((element) {
          issueList!.add(Issue.fromJson(element));
        });
        issueData = IssueData(
          count: decodedResponse["count"],
          nextQuery: decodedResponse["next"],
          previousQuery: decodedResponse["previous"],
          issueList: issueList,
        );
      }
    } catch (e) {
      print(e);
    }
    return issueData;
  }

  static Future<void> postIssue(Issue issue, BuildContext parentContext) async {
    http.Response? response;
    // HttpClient httpClient = HttpClient();
    try {
      // HttpClientRequest req = await httpClient.postUrl(
      //   Uri.parse(IssueEndPoints.issues),
      // );
      // req.headers.set('content-type', 'application/json');
      // req.headers.set('Accept', 'application/json');
      // req.add(utf8.encode(jsonEncode(issue.toJson())));
      // req.
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(IssueEndPoints.issues),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          "screenshot",
          issue.ocr,
        ),
      );
      request.headers.addAll({
        "accept": "application/json",
        "Content-Type": "application/json",
      });
      issue.toJson().forEach((key, value) {
        request.fields[key] = jsonEncode(value);
      });
      print(request.fields);

      var streamedresponse = await request.send();

      print(streamedresponse);
      response = await http.Response.fromStream(streamedresponse);

      print(response.body);

      if (streamedresponse.statusCode == 200) {
        response = await http.Response.fromStream(streamedresponse);
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        issue = Issue.fromJson(decodedResponse);

        SnackBar thankSnack = SnackBar(
          content: Text("Thanks for reporting the issue!"),
        );
        ScaffoldMessenger.of(parentContext).showSnackBar(thankSnack);

        Navigator.of(parentContext).pushNamed(
          RouteManager.issueDetailPage,
          arguments: issue,
        );
      } else {
        ScaffoldMessenger.of(parentContext).clearSnackBars();
        SnackBar errorSnack = SnackBar(
          content: Text("There was some error, please try again!"),
        );
        ScaffoldMessenger.of(parentContext).showSnackBar(errorSnack);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future getAllUserIssues() async {}

  static Future getUserIssueById() async {}

  static Future searchUserIssueByKeyWord() async {}
}
