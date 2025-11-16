import ContextComponent from '../context/context-component';
import { AppState } from '../templates/application.gjs';
import { on } from '@ember/modifier';

export class UserName extends ContextComponent {
  constructor(owner, args, context) {
    super(...arguments);

    this.appState = context.getContext(AppState);
  }

  updateUserName = (ev) => {
    this.appState.userName = ev.target.value;
  };

  <template>
    <div>
      <label for="username">User Name: </label>
      <input
        id="username"
        type="text"
        value={{this.appState.userName}}
        {{on "input" this.updateUserName}}
      />
      <p>Your user name is: {{this.appState.userName}}</p>
    </div>
  </template>
}
