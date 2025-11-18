import Component from '@glimmer/component';
import { ProvideContext } from '../context/context-component';
import { UserName } from './UserName.gjs';
import { AppState } from '../state/app-state';

const footerAppState = new AppState();
footerAppState.userName = 'Footer User';

export class Footer extends Component {
  <template>
    <ProvideContext @key={{AppState}} @value={{footerAppState}}>

      <UserName />

    </ProvideContext>
  </template>
}
