# cbwire-cli

## The UN-Official CommandBox CLI for CBWIRE!

If you are anything like me you will happily spend hours coding to save yourself a few minutes 🤣. Here is my latest result of saving myself a few minutes. I present the UN-Official CBWIRE CLI! It is primarily used for scaffolding wires and has many options. I'm not sure if there is much else that a CLI could do to expedite and streamline the use of CBWIRE but let me know if you have any ideas! I tried to include lots of comments and links to the CBWIRE docs to help get you started. I hope it helps. Enjoy!

## Installation

Install the commands via CommandBox like so:

`box install git://github.com/mrigsby/cbwire-cli.git`

It can be installed via the gitub repo until its ready to be published on ForgeBox

*💡 Be sure to change into the root of you commandbox application or include the `appMapping` argument*

## Command Line Arguments

- `name` : String : Name of the wire to create without extensions. @module can be used to place in a module wires directory.
- `dataProps` : String : A comma-delimited list of data property keys to add.
- `lockedDataProps` : String : A comma-delimited list of data property keys to lock.
- `actions` : String : A comma-delimited list of actions to generate
- `outerElement` : String : The outer element type to use for the wire. Defaults to "div"
- `jsWireRef` : Boolean : If true, the livewire:init & component.init hooks will be included and a reference to $wire will be created as window.wirename = $wire
- `lifeCycleEvents` : String : A comma-delimited list of life cycle events to generate. If none provided, only onMount() will be generated.
- `onHydrateProps` : String : A comma-delimited list of properties to create onHydrate() Property methods for in the wire.
- `onUpdateProps` : String : A comma-delimited list of properties to create onUpdate() Property methods for in the wire.
- `wiresDirectory` : String : The directory where your wires are stored. Defaults to standard `wires` directory.
- `appMapping` : String : The root location of the application in the web root: ex: /MyApp or / if in the root
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