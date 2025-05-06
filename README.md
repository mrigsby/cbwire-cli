# cbwire-cli

## The UN-Official CommandBox CLI for CBWIRE!

Primarily a used to scaffold wires with mulitple options

## Installation

Install the commands via CommandBox like so:

`box install cbwire-cli`

## Command Line Arguments

- `name` : String : Name of the wire to create without extensions. @module can be used to place in a module wires directory.
- `dataProps` : String : A comma-delimited list of data property keys to add.
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

## Examples

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --open --force`
