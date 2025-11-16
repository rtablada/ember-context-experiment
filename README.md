# Try Context

This repo is an attempt to find a way to introduce context behavior in Ember core inspired by how Vue implemented context

## Motivation

Ember does not have a public API that allows for context to be created without using very private APIs.
This makes it hard to reason about for developers who are used to context in other frameworks like Vue or React.
It also limits some behavior or cross framework interoperability (ie making Radix compatible implementations in Ember).

## What is this repo?

This repo is a minimum viable implementation of context behavior in Ember.
It has two small patches to `ember-source` and `@glimmer/component` to that make the following changes to allow public API for better context experimentation:

1. export `EmberGlimmerComponentManager` from `@glimmer/component` this way the component manager can be extended to pass in context
2. change `InternalManager.create` to pass in the parent stack to `Manager.createComponent` this way the parent component instance crawl the stack to find the latest ContextProvider in the stack

## How this works

This implementation creates a new base component that takes `ContextContainer` as a third argument in the constructor.
This `ContextContainer` has a method `getContext<T>(key: ContextKey<T>): T` that allows for getting context by key.
There is also a `ProvideContext` component that allows for providing context to descendants.

### Surprises when working through things

I originally thought that the context container would need to be a complex set of WeakMaps to allow key storage, but in reality in this implmentation the context container knows if the key lookup is for the current provider, if not delegate to the next context container up the stack.

When traversing the stack I check to see if `frame.state.component` is an instance of `ProvideContext`.
I traverse the stack in reverse to find the closeset path provider first.

## Issues with other current implementations

`ember-provide-consume-context` allows for a context like behavior but has 3 major issues:

1. It uses private APIs by registering things into the private glimmer op codes, this means it can break or be incompatible with future versions of Ember.
2. It uses decorators as the primary means of defining context providers and consumers, this makes it harder to reason about and use in more reusable composable functions.
3. It does not allow evaluating context in constructors due to the way that context is registered and consumed using decorators

`ember-primatives` allows for context but has two major issues

1. It only allows for provide/consume as components and is not usable in JS
2. It relies on DOM traversal meaning that context can only be consumed by descendants in the DOM tree, this means it is not usable in modal or other portal situations

## Implementation strategy here

The core idea of this implementation is inspired by Vue's implementation of context.
In Vue, the constructor of a component receives the component attributes and THEN context as a second argument.
This was added as a later addition to Vue and could be added to Ember today with no need to rewrite the entire rendering engine.
It is also forward compatible with a future rendering engine since the interface defined could be very shallow.

So the constructor for Glimmer components would change from:

```ts
constructor(owner: Owner, args: Args) : Component
```

To

```ts
interface ContextContainer {
  // A method to get context by key
  getContext<T>(key: ContextKey<T>): T;
}

constructor(owner: Owner, args: Args, context: ContextContainer) : Component
```

Note here that at least in the first implementation the context container does not allow for setting context, only getting it.
This is because context containers are essentially a proxy to the parent context container in their implementation.
Setting up context is a bit more private API and the public interface would be through a component

```hbs
<ProvideContext @key={{this.key}} @value={{this.value}}>{{yield}}</ProvideContext>
```

## What needs to change

Creating a component class with a third argument in the constructor is actually fairly straightforward and can be done today.
`@glimmer/manager` also allows for registering a new component manager that can pass in the third argument.
However the hard part is finding the way to reference the parent context object from within the component manager.

This is because `Manager.createComponent` as an interface only receives the component class constructor and named `@` args for the component.

In my research it seems that we would want to instead change `Manager.createComponent` to receive the vmArgs.stack from `InternalManager.create` which has the parent component instance.

Currently `InternalManager.create` is defined as:

```ts
create(owner, definition, vmArgs) {
  let delegate = this.getDelegateFor(owner),
    args = argsProxyFor(vmArgs.capture(), "component"),
    component = delegate.createComponent(definition, args);
  return new CustomComponentState(component, delegate, args);
}
```

This would change to

```ts
create(owner, definition, vmArgs) {
  let delegate = this.getDelegateFor(owner),
    args = argsProxyFor(vmArgs.capture(), "component"),
    component = delegate.createComponent(definition, args, vmArgs.stack);
  return new CustomComponentState(component, delegate, args);
}
```


This change would allow for experimentation in ContainerManagers to be able to crawl the parent stack and do things like making context providers and consumers.
This would allow for addons to do experimentation without requiring core adoption.
