\# VULN-03 – IDOR / Broken Access Control



\## Vulnerability



The NodeGoat allocations route accepted a user ID from the URL:



`/allocations/:userId`



The application verified that the requester was logged in, but it used

`req.params.userId` to determine which user's allocation data should

be retrieved.



This allowed an authenticated user to manipulate the URL and request

another user's allocation information.



\## Affected File



`app/routes/allocations.js`



\## Before Remediation



The application used:



```javascript

const {

&#x20;   userId

} = req.params;

