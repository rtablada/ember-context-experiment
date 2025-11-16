import { pageTitle } from 'ember-page-title';
import { tracked } from '@glimmer/tracking';
import ContextComponent, { ProvideContext } from '../context/context-component';
import { UserName } from '../components/UserName.gjs';

export class AppState {
  @tracked userName;

  constructor() {
    this.userName = 'Guest';
  }
}

const myAppState = new AppState();

<template>
  <ProvideContext @key={{AppState}} @value={{myAppState}}>
    {{pageTitle "TryContext"}}
    <h2 id="title">Welcome to Ember</h2>
    {{outlet}}

    <UserName />

    <UserName />
  </ProvideContext>
</template>
