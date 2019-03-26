'use strict';
import { environment } from './environments'
import Amplify, { Auth } from 'aws-amplify';
import { Observable, BehaviorSubject, from, of, map, catchError, mergeMap } from 'rxjs';
import * as axios from 'axios';

require("./styles.scss");

const {Elm} = require('./Main');
var app = Elm.Main.init();

Amplify.configure(environment.amplify);

const loggedIn = new BehaviorSubject(false);
const signIn$ = from(Auth.signIn('user', 'pass'));

signIn$.subscribe(signIn => {
  const instance = axios.create({
    baseURL: environment.apiBaseUrl,
    headers: {
      'Authorization': signIn.signInUserSession.idToken.jwtToken
    }
  });
  instance.get('/pets').then(response =>
    console.log(response)
  ).catch(error =>
    console.log(error)
  );
});
