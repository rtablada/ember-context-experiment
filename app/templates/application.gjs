import { pageTitle } from 'ember-page-title';
import ContextComponent, { ProvideContext } from '../context/context-component';
import { UserName } from '../components/UserName.gjs';
import { AppState } from '../state/app-state';
import { Footer } from '../components/Footer.gjs';

const myAppState = new AppState();

<template>
  <ProvideContext @key={{AppState}} @value={{myAppState}}>
    {{pageTitle "TryContext"}}
    <h2 id="title">Welcome to Ember</h2>
    {{outlet}}

    <UserName />

    <Footer />
  </ProvideContext>
</template>
