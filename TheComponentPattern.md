# The Component Pattern

The Component Pattern is a pattern I have identified in well structured systems. Software systems are a combination of structure, behavior, and state. Components define the structure of software systems. They are objects that have Actions, and Events. Components of a system are composed together in the pattern shown below. 
The goals are:

![](../resources/images/ComponentPattern.jpg)



A system composed from components. Arrows pointing in represent action methods. Arrows pointing out represent events. Outer component reacts to events of inner components. This keeps dependencies pointing inward. With composition of calls made inward, and events outward, no inner component is dependent on an outer component. Because the dependencies flow in the direction of composition of the system , the dependencies are inherent in the system itself.
