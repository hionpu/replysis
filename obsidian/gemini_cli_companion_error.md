In a devcontainer setup, the Gemini Companion extension sets a dynamic GEMINI_CLI_IDE_SERVER_PORT environment variable each time the container starts. However, this port is not automatically forwarded, so gemini-cli inside the container cannot connect to the IDE server unless the correct port is manually forwarded.

✅ Temporary Workaround
Ensure the Gemini CLI Companion extension is installed and running inside the devcontainer

Open Command Palette → Developer: Show Running Extensions
Confirm that google.gemini-cli-vscode-ide-companion is listed and active
Open a terminal inside the devcontainer

Run:

```
echo $GEMINI_CLI_IDE_SERVER_PORT
Open the Command Palette → > Forward a Port
```

Enter the port shown above (e.g. 33419)

Start gemini-cli:

gemini
Inside the CLI, check if IDE integration is enabled:

/ide enabled
Then verify connection:

/ide status
💡 Without forwarding this dynamic port manually, gemini-cli will hang or fail to connect to the IDE extension.