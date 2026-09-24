# VULN-01 – Plaintext Password Storage

## Vulnerability Overview

The NodeGoat application stored user passwords directly in the MongoDB database without cryptographic password hashing.

The vulnerability was identified in:

`app/data/user-dao.js`

When a new user was created, the password received from the registration request was assigned directly to the `password` property of the user document.

## Vulnerable Code

```javascript
const user = {
    userName,
    firstName,
    lastName,
    benefitStartDate: this.getRandomFutureDate(),
    password
};
```

The login implementation also performed a direct plaintext comparison:

```javascript
const comparePassword = (fromDB, fromUser) => {
    return fromDB === fromUser;
};
```

## Security Impact

If an attacker obtained read access to the application's user collection, user passwords could be disclosed directly.

Password reuse could increase the impact if a disclosed password was also used by the same user on another system.

## STRIDE Mapping

**STRIDE Category:** Information Disclosure

**Affected Components:**

* NodeGoat web application
* MongoDB users collection
* Application-to-database trust boundary

## Risk Assessment

| Attribute  | Rating   |
| ---------- | -------- |
| Likelihood | High (3) |
| Impact     | High (3) |
| Risk Score | 9        |
| Risk Level | High     |

## Vulnerability Verification

A controlled test account was created in the authorised local NodeGoat environment.

Test username:

`vuln01test`

The MongoDB user record was then inspected.

Before remediation, the database contained the original password value:

```text
"userName" : "vuln01test"
"password" : "Test123!"
```

This demonstrated that the application stored the user's password in plaintext.

Evidence:

`evidence/vuln-01/01-before-plaintext-password.png`

## Remediation

Password storage was modified to use bcrypt hashing before data is written to MongoDB.

The secure implementation uses:

```javascript
password: bcrypt.hashSync(password, bcrypt.genSaltSync())
```

Authentication was also modified so that the plaintext password supplied during login is checked against the stored bcrypt hash:

```javascript
const comparePassword = (fromDB, fromUser) => {
    return bcrypt.compareSync(fromUser, fromDB);
};
```

The application therefore no longer requires the original password to be stored in the database.

## Post-Remediation Verification

After rebuilding the application, a new controlled test account named `vuln01fixed` was created.

Inspection of the MongoDB record confirmed that the original password was no longer stored directly. Instead, the password field contained a bcrypt hash.

Evidence:

`evidence/vuln-01/02-after-hashed-password.png`

The `vuln01fixed` account was also tested through the NodeGoat login page using the original test password. Successful authentication confirmed that normal login functionality continued to operate after password hashing was introduced.

Evidence:

`evidence/vuln-01/03-after-login-success.png`

## Before and After Comparison

| Test                                    | Before Remediation       | After Remediation      |
| --------------------------------------- | ------------------------ | ---------------------- |
| Password stored in MongoDB              | Plaintext                | bcrypt hash            |
| Original password visible from database | Yes                      | No                     |
| Authentication mechanism                | Direct string comparison | bcrypt hash comparison |
| User login functionality                | Working                  | Working                |

## Result

The remediation successfully prevents newly registered user passwords from being stored in plaintext while preserving application authentication functionality.
