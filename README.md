# cbwire-cli

## The UN-Official CommandBox CLI for CBWIRE!

If you are anything like me you will happily spend hours coding to save yourself a few minutes of work 🤣. The `cbwire-cli` CommandBox module is the result of saving myself a few minutes of work. In the initial release it was only used for scaffolding wires. In the version 1 release more functionality was added:

- Create `BoxLang` wires (.bx & .bxm)
- Set your own personal defaults for arguments. See ["Want custom defaults?"](#want-custom-defaults) section below
- Handy functions if you are contributing to the `cbwire` module.

I hope those using `cbwire` find the `cbwire-cli` CommandBox module as helpful as I do. 

Enjoy and welcome to the UN-Official CBWIRE CLI! 


## Installation

Install via CommandBox like so:

`box install cbwire-cli`

## Scaffolding Wires

Scaffolding out new wires is now easy-peasy! With a quick command you can generate your wires and be on your way! Below you will find a plethora of examples to get you started. 

> 💡 Be sure to change into the root of your ColdBox application or include the `appMapping` argument before running commands

### Arguments

| Argument | Initial Default Value | Description | Customizable Defaults Key |
|:----------|:--------|:---------|:---------|
| name | [empty string] | Name of the wire to create without extensions. @module can be used to place in a module wires directory | dev.create.wire.name |
| dataProps | [empty string] | comma-delimited list of data property keys to add | dev.create.wire.dataProps |
| lockedDataProps | [empty string] | comma-delimited list of data property keys to lock | dev.create.wire.lockedDataProps |
| actions | [empty string] | comma-delimited list of actions to generate | dev.create.wire.actions |
| outerElement | div | outer element type to use for the wire | dev.create.wire.outerElement |
| lifeCycleEvents | [empty string] | comma-delimited list of life cycle events names to generate. If none provided, only onMount() will be generated but commented out | dev.create.wire.lifeCycleEvents |
| onHydrateProps | [empty string] | comma-delimited list of properties to create onHydrate() Property methods for in the wire | dev.create.wire.onHydrateProps |
| wiresDirectory | [empty string] | directory where your wires are stored. Defaults to standard `wires` directory | dev.create.wire.wiresDirectory |
| appMapping | [empty string] | root location of the application in the web root: ex: MyApp/ or leave blank if in the root | dev.create.wire.appMapping |
| description | [empty string] | wire component hint description | dev.create.wire.description |
| jsWireRef | false | If true, the livewire:init & component.init hooks will be included and a reference to $wire will be created as window.wirename = $wire | dev.create.wire.jsWireRef |
| open | false | If true open the wire component & template once generated | dev.create.wire.open |
| singleFileWire | false | If true creates a single file wire | dev.create.wire.singleFileWire |
| boxlang | false | Create the wire using boxlang (.bx & .bxm) | dev.create.wire.boxlang |
| includePlaceholder | false | If true inserts a placeholder action in the wire component for lazy loading wires | dev.create.wire.includePlaceholder |
| force | false | If true force overwrite of existing wires | dev.create.wire.force |

### Create Wire Examples

#### Basic Example

`cbwire create wire myWireName`

#### Basic Example - Create BoxLang Wire ( myWireName.bx & myWireName.bxm )

`cbwire create wire myWireName --boxlang`

#### Basic Example with pre-configured data properties, actions, the javascript code to create a global reference and opens the wired for editing

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

#### Basic Example with module name using myWireName@MyModuleName

`cbwire create wire name="myWireName@MyModuleName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

#### Many options (WITHOUT singleFileWire)

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" lockedDataProps="counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --boxlang --open --force`

#### Many options (WITH singleFileWire)

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" lockedDataProps="counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --boxlang --open --force --singleFileWire`

## Want custom defaults?

cbwire-cli has the ability to set the default values that are used for actions and the ability to reset all values to the original defaults. What does this mean for you? It means if you primarily use single file wires on all your projects, you can use `cbwire default set create.singleFileWire true` and it will change your default value for the `singleFileWire` argument when using `cbwire create wire` action!

> 💡 Any default changes are global for CommandBox, NOT just the current project.

The default setting keys follow the pattern of `[ACTION PATH IN DOT NOTATION].[ARGUMENT]`, meaning for the create action and boxlang argument you would use `cbwire default set create.boxlang true` to set your new default for the `boxlang` argument to always be true.

You can also reset all defaults to the original settings with `cbwire default reset`. Alternatively you can reset a single default to the original setting by passing in the key. For example `cbwire default reset create.wire.boxlang` to reset just the `create.wire.boxlang` key and leave all other custom defaults un-touched.

In addition you can view all defaults by calling `cbwire default get` or alternatively you can view a single default setting by passing in the key, for example `cbwire default get create.wire.boxlang`.

> 💡 Uninstalling or re-installing cbwire-cli will overwrite the custom defaults and reset all to original base values


### Default Settings Examples

Want to always open wires after they are created?

`cbwire default create.open true`

Want to always include data properties of `showAlert` and `showAlertMessage` by default?

`cbwire default set create.dataProps showAlert,showAlertMessage`

Want to always create boxlang wires by default? 

`cbwire default set create.boxlang true`

Want to always include the `onHydrate` and `onRender` lifecycle methods by default?

`cbwire default set create.lifeCycleEvents onHydrate,onRender`

Want to change the wire description comment to include something other than the standard "This wire was created by the cbwire CLI! Please update me!"?

`cbwire default set create.description "Created By John Doe jdoe@jdoe.tld"`

## Contributing to the CBWIRE Module?

The `cbwire-cli` module has a few helper functions to assist in the development of and contribution to the `cbwire` module to make some steps a little easier. All of these commands are in the `cbwire dev` namespace.

> 💡 All `cbwire dev` commands are designed to be run from the `cbwire` root or test-harness directory!

> 💡 **Did you know?** Ortus Solutions has a great **Ortus Coding Style Guide**! [Check it out here:](https://github.com/Ortus-Solutions/coding-standards) https://github.com/Ortus-Solutions/coding-standards

### Preparing test-harness server

Before you can run TestBox tests, the test-harness server needs to install ColdBox dependencies! To simplify this you can run the following command that will attempt to move to the `cbwire` module root directory, run the `install` command to install cbwires's ColdBox dependencies and then move to the `test-harness` directory and run the `install` command again to install the `test-harness` server ColdBox dependencies.

`cbwire dev server prepare`

### Running test-harness servers

The `CBWIRE` module has pre-configured CommandBox server json files for all supported engines in the `test-harness` directory. To run a server and optionally run the TestBox tests you can run the following commands from CommandBox when in the root of the `CBWIRE` module or the `test-harness` directory.

`cbwire dev server start`

The `cbwire dev server start` command has the following arguments. The default values can be set to your personal preference using the Custom Defaults options above!

| Argument | Initial Default Value | Description | Customizable Defaults Key |
|:----------|:--------|:---------|:---------|
| webRunner | false | open the TestBox Web Runner in the default browser | dev.server.start.webRunner |
| commandBoxRunner | true | run the TestBox CommandBox Runner | dev.server.start.commandBoxRunner |
| defaultServer | 'server-boxlang-cfml@1.json' | The default server config file to be selected in the list of servers to start | dev.server.start.defaultServer |
| stopRunningTestServers | true | stop any running test-harness servers before starting the selected server | dev.server.start.stopRunningTestServers |

#### Examples

Run TestBox CommandBox Runner after server start

`cbwire dev server start --commandBoxRunner`

Run TestBox CommandBox Runner and open the TestBox Web Runner after server start

`cbwire dev server start --commandBoxRunner --webRunner`

If you want to always run the TestBox Web Runner after starting a server you can use this example to set the default value for the `webRunner` argument to true

`cbwire default set dev.server.start.webRunner true`

### Stopping ANY test-harness servers running

This will stop any currently running test-harness servers. It has no arguments. It will loop through all test-harness servers and stop any server that may be running. 

`cbwire dev server stop`

> Note: The `cbwire dev server start` and `cbwire dev test` does this automatically before running

### Forgetting test-harness servers

Sometimes it's helpful in the development process to use the CommandBox `server forget` option. The CBWIRE CLI provides a quick and easy way to forget a single server or all servers in the `test-harness` directory. When run you will be given the option to select a single server to forget or the option to forget all.

#### Example

There's only one command for forgetting `test-harness` server(s). When run it will give you options to select a specific server to forget or the option to forget all test-harness servers.

`cbwire dev server forget`

### Running test-harness server TestBox tests

You can run TestBox tests for one or all engines configured for the test-harness server. 

`cbwire dev tests`

When you run the command above you are asked which engine you want to use to run tests for with the option to run the tests for for ALL engines. The results will for any tests run will be aggregated and displayed after it is complete. The function follows the following steps:

1. Prompts for selection of one or all engines
2. *Removes any previous test results
3. *Stops any running test-harness servers
4. Starts each test-harness server
5. Runs TestBox runner saving the results to files
6. Aggregates all test results
7. Displays the aggregated results
8. If any servers had errors or fails asks to open the results for these in your browser

> Note: Steps above marked with * can be have their default value set with custom argument defaults

#### Arguments

| Argument | Initial Default Value | Description | Customizable Defaults Key |
|:----------|:--------|:---------|:---------|
| deletePreviousReports | true | If any previous test results should be deleted | dev.tests.deletePreviousReports |
| defaultServer | 'ALL' | The Server/Option to be selected by default (server json file name or ALL) | dev.tests.defaultServer |

#### Example

`cbwire dev tests --deletePreviousReports`

`cbwire dev tests defaultServer="server-boxlang-cfml@1.json"`

`cbwire dev tests deletePreviousReports=false defaultServer="server-boxlang-cfml@1.json"`

---

## Developed By


```JSON
"developedBy" : {
	"name" 		: "Michael V. Rigsby",
	"company" 	: "OIS Technologies",
	"email" 	: "mrigsby@oistech.com",
	"website" 	: "https://www.oistech.com"
}
```
> "It's really complex to make something simple." -Jack Dorsey

[OIS Technologies](https://www.oistech.com) | [CBWire Documenation](https://cbwire.ortusbooks.com/) | [LiveWire Docs](https://livewire.laravel.com/) | [AlpineJS Docs](https://alpinejs.dev/start-here)
