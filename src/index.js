'use strict';
import { environment } from './environments'
import Amplify, { Auth } from 'aws-amplify';
import { Observable, from, of } from 'rxjs';
import * as axios from 'axios';

require("./styles.scss");

const {Elm} = require('./Main');
var app = Elm.Main.init({ flags: { apiBaseUrl: environment.apiBaseUrl } });

Amplify.configure(environment.amplify);

app.ports.signup.subscribe(user => {
  const { username, email, password } = user;
  console.log(username);
  Auth.signUp({
    username,
    password,
    attributes: {
        email
    },
    validationData: []
    })
    .then(data => console.log(data))
    .catch(err => console.log(err));
});

app.ports.confirm.subscribe(confirmInfo => {
  const { username, code } =  confirmInfo;
  Auth.confirmSignUp(username, code, {
    forceAliasCreation: true
}).then(data => console.log(data))
  .catch(err => console.log(err));
});

app.ports.signin.subscribe(user => {
  const { username, password } = user;
  from(Auth.signIn(username, password)).subscribe(signIn => {
    app.ports.sendToken.send(signIn.signInUserSession.idToken.jwtToken);
  });
});


app.ports.signout.subscribe(_ => {
  Auth.signOut().then(() => {
    this.setState({authState: 'signIn'});
  }).catch(e => {
    console.log(e);
  });
});
