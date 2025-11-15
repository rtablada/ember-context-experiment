import Component from '@glimmer/component';
import { pageTitle } from 'ember-page-title';

export default class Application extends Component {
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
