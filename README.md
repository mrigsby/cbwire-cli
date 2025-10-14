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
- `lifeCycleEvents` : String : A comma-delimited list of life cycle events names to generate. If none provided, only onMount() will be generated but commented out.
- `onHydrateProps` : String : A comma-delimited list of properties to create onHydrate() Property methods for in the wire.
- `onUpdateProps` : String : A comma-delimited list of properties to create onUpdate() Property methods for in the wire.
- `wiresDirectory` : String : The directory where your wires are stored. Defaults to standard `wires` directory.
- `appMapping` : String : The root location of the application in the web root: ex: MyApp/ or leave blank if in the root
- `description` : String : The wire component hint description
- `jsWireRef` : Boolean : If true, the livewire:init & component.init hooks will be included and a reference to $wire will be created as window.wirename = $wire
- `open` : Boolean : If true open the wire component & template once generated
- `singleFileWire` : Boolean : If true creates a single file wire
- `boxlang` : Boolean : Create the wire using boxlang (.bx & .bxm)
- `includePlaceholder`	: Boolean : If true inserts a placeholder action in the wire component for lazy loading wires
- `force` : Boolean : If true force overwrite of existing wires

## Create Wire Examples

#### Super Basic Example

`cbwire create wire myWireName`

#### Super Basic Example - Create BoxLang Wire ( myWireName.bx & myWireName.bxm )

`cbwire create wire myWireName --boxlang`

#### Basic Example

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

#### Basic Example with module name using myWireName@MyModuleName

`cbwire create wire name="myWireName@MyModuleName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`

#### Many options (WITHOUT singleFileWire)

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" lockedDataProps="counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --boxlang --open --force`

#### Many options (WITH singleFileWire)

`cbwire create wire name="myWireName" dataProps="counter1,counter2,counter3" lockedDataProps="counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --boxlang --open --force --singleFileWire`

### Want custom defaults?

cbwire-cli has the ability to set these default values that will be used for all future actions and the ability to reset all values to the original defaults. What does this mean for you? It means if you primarly use single file wires on all your projects, you can use `cbwire default set create.singleFileWire true` and it will change your default value for singleFileWire when using the create action to true!

> Note: Any default changes are global for CommandBox, NOT just the current project.

The default setting keys follow the pattern of `[ACTION].[ARGUMENT]`, meaning for the create action and boxlang argument you would use `cbwire default set create.boxlang true` to set your new default for the `boxlang` argument to always be true.

You can also reset all defaults to the orginal settings with `cbwire default reset`. Alternativly you can reset a single default to the original setting by passing in the key. For example `cbwire default reset create.boxlang` to reset just the `create.boxlang` key and leave all other custom defaults un-touched.

In addition you can view all defaults by calling `cbwire default get` or alternativly you can view a single default setting by passing in the key, for example `cbwire default get create.boxlang`.

> Note: uninstalling or re-instlaling cbwire-cli will overwrite the custom defaults and reset all to original base values


#### Default Settings Examples

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