Instructions for Running the PreInstallCheck tool:

1. Import the PreInstallCheck.psm1 module. You will use this command: Import-Module [Path]\PreInstallCheck.psm1 *Note:(Replace [Path] with the actual location of the directory.)

2. The input.csv file, located in the PreInstallCheck zip file, should be updated before running the tool. Only the first and second columns should be updated. List all Relativity server hostnames in the ServerName column and their corresponding server roles in the ServerRole column. For example, if emttest is a Primary SQL Server, you should put emttest in the ServerName column and sql in the ServerRole column. These are the possible entries for ServerRole: sql, secretStore, distributedSql, serviceBus, web, coreAgent, dtSearchAgent, conversionAgent, analytics, invariantSql, queueManager, worker, file, smtp

3. Run the Start-PreInstallCheck commandlet. Example: Start-PreInstallCheck -inputPath C:\input.csv -sql -secretStore -distributedSql -serviceBus -web -coreAgent -dtSearchAgent -conversionAgent -analytics -invariantSql -queueManager -worker -file -smtp

4. You may choose which servers are checked by adding or removing a flag (i.e. -sql) in the Start-PreInstallCheck commandlet.

5. You may run the tool on all servers by using the -all flag. Example: Start-PreInstallCheck -inputPath C:\input.csv -all

6. If a specific server script fails, it will write "No output was returned" in the output file and continue on with the rest of the checks.

7. All output from the tool will be written to c:\output.csv.

8. If checking a SQL Server, the script will ask for sysadmin SQL (NOT WinAuth) credentials for the SQL Server Instance on that server.
