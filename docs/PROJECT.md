# DevSecOps Security Pipeline

## Project Overview

This project focuses on building and securing a DevSecOps pipeline using OWASP NodeGoat as the selected open-source application. NodeGoat is an intentionally vulnerable Node.js web application that will be used to demonstrate how security can be integrated throughout the software development and deployment lifecycle.

The project will analyse the application's architecture, identify security threats using the STRIDE threat-modelling methodology, assess security risks, demonstrate selected vulnerabilities in an authorised local environment, and implement appropriate secure coding fixes.

The application is containerised using Docker and Docker Compose, with the NodeGoat web application communicating with a MongoDB database.

A CI/CD security pipeline will also be implemented using GitHub Actions. The pipeline will integrate security controls including:

* Static Application Security Testing (SAST)
* Software Composition Analysis (SCA) and dependency scanning
* Secrets scanning
* Container image vulnerability scanning
* Automated security gates

The project will demonstrate the difference between vulnerable and remediated versions of the application and evaluate how automated DevSecOps security controls can identify and prevent security issues from progressing through the software delivery pipeline.

## Selected Application

**Application:** OWASP NodeGoat

**Technology Stack:**

* Node.js
* Express.js
* MongoDB
* Docker
* Docker Compose

## Current Architecture

The current application consists of two main containerised components:

1. **NodeGoat Web Application** – Provides the web application and runs on Node.js/Express.
2. **MongoDB Database** – Stores application data and communicates with the NodeGoat web application.

The NodeGoat web application is exposed locally on port `4000`, while the application communicates internally with MongoDB on port `27017`.

## Project Repository

**Repository Name:** `devsecops-security-pipeline`

The repository contains the original OWASP NodeGoat application as the project baseline. Project-specific security documentation, threat models, vulnerability investigations, security scan results, CI/CD configurations, and remediation work will be added throughout the project.

## Team

This project is completed by a team of four members. Contributions will be tracked using Git commits, branches, and pull requests.

## Security Testing Scope

All vulnerability testing and exploit demonstrations will be performed only against the team's authorised local or containerised NodeGoat environment. Testing will not target external or unauthorised systems.
