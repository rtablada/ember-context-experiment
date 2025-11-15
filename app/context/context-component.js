import Component, { EmberGlimmerComponentManager } from '@glimmer/component';
import { setComponentManager } from '@glimmer/manager';

export const CONTEXT_KEY = Symbol.for('ember-context');

export default class ContextComponent extends Component {
  constructor(owner, args, context) {
    super(owner, args);
    this.context = context;
  }
}

class ContextComponentManager extends EmberGlimmerComponentManager {
  createComponent(ComponentClass, args, stack) {
    debugger;

    return new ComponentClass(this.owner, args.named);
  }
}

setComponentManager(
  (owner) => new ContextComponentManager(owner),
  ContextComponent
);
