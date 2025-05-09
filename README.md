# cbwire-cli

## The UN-Official CommandBox CLI for CBWIRE!

If you are anything like me you will happily spend hours coding to save yourself a few minutes of work 🤣. Here is the result of saving myself a few minutes of work. The UN-Official CBWIRE CLI! It is currently only used for scaffolding wires and has many of the most used options included. I'm not sure if there is much else that a CLI could do to expedite and streamline the use of CBWIRE but let me know if you have any ideas! I tried to include lots of comments and links to the CBWIRE docs in the generated wires to help get you started. I hope you find it as helpful as I do. Enjoy!

## Installation

Install via CommandBox like so:

`box install cbwire-cli`

*💡 Be sure to change into the root of your ColdBox application or include the `appMapping` argument before running commands*

## Command Line Arguments

- `name` : String : Name of the wire to create without extensions. @module can be used to place in a module wires directory.
- `dataProps` : String : A comma-delimited list of data property keys to add.
- `lockedDataProps` : String : A comma-delimited list of data property keys to lock.
- `actions` : String : A comma-delimited list of actions to generate
- `outerElement` : String : The outer element type to use for the wire. Defaults to "div"
- `jsWireRef` : Boolean : If true, the livewire:init & component.init hooks will be included and a reference to $wire will be created as window.wirename = $wire
- `lifeCycleEvents` : String : A comma-delimited list of life cycle events names to generate. If none provided, only onMount() will be generated but commented out.
- `onHydrateProps` : String : A comma-delimited list of properties to create onHydrate() Property methods for in the wire.
- `onUpdateProps` : String : A comma-delimited list of properties to create onUpdate() Property methods for in the wire.
- `wiresDirectory` : String : The directory where your wires are stored. Defaults to standard `wires` directory.
- `appMapping` : String : The root location of the application in the web root: ex: MyApp/ or leave blank if in the root
- `description` : String : The wire component hint description
- `open` : Boolean : If true open the wire component & template once generated
- `force` : Boolean : If true force overwrite of existing wires
- `singleFileWire` : Boolean : If true creates a single file wire
- `includePlaceholder`	: Boolean : If true inserts a placeholder action in the wire component for lazy loading wires

## Examples

Please note that CBWIRE CLI registers two command alias's: `create wire` and `wire create`. The means that in all the examples below you can leave out the `cbwire` part altogether if you prefer. So `cbwire create wire myWireName` could be `create wire myWireName`. Its your choice! 

#### Super Basic Example

`cbwire create wire myWireName`

#### Basic Example

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

#### Basic Example with module name using myWireName@MyModuleName

`cbwire create wire name="myWireName@MyModuleName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

#### Many options (WITHOUT singleFileWire)

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" lockedDataProps="counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --open --force`

#### Many options (WITH singleFileWire)

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" lockedDataProps="counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --open --force --singleFileWire`