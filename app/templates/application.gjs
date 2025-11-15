import { pageTitle } from 'ember-page-title';
import ContextComponent from '../context/context-component';

export default class Application extends ContextComponent {
  constructor() {
    super(...arguments);
    debugger;
  }

  <template>
    {{pageTitle "TryContext"}}
    <h2 id="title">Welcome to Ember</h2>

    {{outlet}}
  </template>
}
