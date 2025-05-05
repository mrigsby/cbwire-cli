# cbwire-cli

The UN-Official CommandBox CLI for CBWIRE!

### Example:

`cbwire create wire name="someWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" --jsWireRef --open`


`cbwire create wire name="someWireName" dataProps="counter1,counter2,counter3" actions="saveSomething,doSomething,GetSomething" outerElement="p" lifeCycleEvents="onRender,onHydrate,onMount,onUpdate" onHydrateProps="counter2,counter3" onUpdateProps="counter1,counter2" description="This is my wire description" --jsWireRef --open --force`