# VULN-02 – Server-Side JavaScript Injection

## Vulnerability Overview

The NodeGoat contributions feature evaluates user-controlled form input using JavaScript `eval()`.

Affected file:

`app/routes/contributions.js`

## Vulnerable Code

```javascript
const preTax = eval(req.body.preTax);
const afterTax = eval(req.body.afterTax);
const roth = eval(req.body.roth);

## Vulnerability Verification

A controlled test was performed against the local NodeGoat environment.

The value `1+2` was submitted in the Employee Pre-Tax contribution field.

Because the application uses:

```javascript
eval(req.body.preTax)


Now we can apply the fix.

In:

```text
app\routes\contributions.js

BEFORE FIX
Input: 1+2
eval("1+2")
Result: 3%     ← JavaScript executed

AFTER FIX
Input: 1+2
parseInt("1+2", 10)
Result: 1%     ← JavaScript not executed

## Post-Remediation Verification

After replacing `eval()` with numeric parsing using `parseInt(..., 10)`,
the same controlled test was repeated.

Input submitted:

`1+2`

Before remediation, the application evaluated the expression and stored/displayed:

`3%`

After remediation, the input was no longer executed as JavaScript. The application interpreted only the numeric portion and stored/displayed:

`1%`

This confirms that the server-side JavaScript expression was no longer evaluated.

Evidence:

`evidence/vuln-02/02-after-eval-blocked.png`

## SAST After Remediation

Tool: Semgrep

Rules run: 200

Findings: 0

Blocking findings: 0

The six findings associated with unsafe `eval()` usage were removed after replacing the vulnerable code with `parseInt(..., 10)`.

## Before and After Comparison

| Test | Before Remediation | After Remediation |
|---|---|---|
| Input | `1+2` | `1+2` |
| Result | `3%` | `1%` |
| JavaScript expression executed | Yes | No |
| Semgrep findings | 6 | 0 |
| Blocking findings | 6 | 0 |

## Result

The remediation successfully removed the unsafe use of `eval()` from the contributions feature.

The same controlled input no longer executes as JavaScript, and the Semgrep findings associated with the vulnerable code decreased from 6 to 0.