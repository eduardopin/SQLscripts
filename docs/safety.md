# Safety and Assumptions

- Do not run diagnostic SQL with privileged accounts unless required.
- Avoid production writes from ad hoc scripts.
- Capture query plans and timing before changing indexes.
- Keep credentials outside the repository.
