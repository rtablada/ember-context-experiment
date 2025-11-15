# Try Context

This repo is an attempt to find a way to introduce context behavior in Ember core inspired by how Vue implemented context

## Motivation

Ember does not have a public API that allows for context to be created without using very private APIs.
This makes it hard to reason about for developers who are used to context in other frameworks like Vue or React.
It also limits some behavior or cross framework interoperability (ie making Radix compatible implementations in Ember).

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
