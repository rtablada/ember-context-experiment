import Component, { EmberGlimmerComponentManager } from '@glimmer/component';
import { setComponentManager } from '@glimmer/manager';

export const CONTEXT_KEY = Symbol.for('ember-context');

export default class ContextComponent extends Component {
  constructor(owner, args, context) {
    super(owner, args);
    this[CONTEXT_KEY] = context;
  }
}

class ContextContainer {
  constructor(key = null, value = null, parent = null) {
    ((this.key = key), (this.value = value), (this.parent = parent));
  }

  getContext(key) {
    if (this.key === key) {
      return this.value;
    } else if (this.parent) {
      return this.parent.getContext(key);
    } else {
      return undefined;
    }
  }
}

function getLatestContextFromStack(components) {
  for (let i = components.length - 1; i >= 0; i--) {
    const component = components[i];

    if (component instanceof ProvideContext) {
      let c = new ContextContainer(
        component.args.key,
        component.args.value,
        component[CONTEXT_KEY]
      );

      return c;
    }
  }

  return new ContextContainer(null, null, null);
}

class ContextComponentManager extends EmberGlimmerComponentManager {
  createComponent(ComponentClass, args, stack) {
    const context = getLatestContextFromStack(stack);

    // This is debug internal and can't be registered...
    this.ARGS_SET.set(args.named, true);

    return new ComponentClass(this.owner, args.named, context);
  }
}

setComponentManager(
  (owner) => new ContextComponentManager(owner),
  ContextComponent
);

export class ProvideContext extends ContextComponent {
  constructor(owner, args, context) {
    super(owner, args, context);

    this[CONTEXT_KEY] = new ContextContainer(args.key, args.value, context);
  }
}
