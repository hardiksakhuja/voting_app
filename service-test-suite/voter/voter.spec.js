// sample_spec.js.js created with Cypress
//
// Start writing your Cypress tests below!
// If you're unfamiliar with how Cypress works,
// check out the link below and learn how to write your first test:
// https://on.cypress.io/writing-first-test
describe('My First Test', () => {
  it('Visits voter webpage', () => {
    cy.visit('http://roost-controlplane:30030/voter')

  cy.intercept(
  {
    method: 'POST', // Route all POST requests
    url: '*ballot*', // that have a URL that matches '/users/*'
  }
).as('postresult')

cy.contains("Docker").click()

cy.wait('@postresult',{ responseTimeout: 35000 }).then((interception) => {

  assert.isNotNull(interception.response.body, '{code: 201, message: "Vote saved sucessfully"}')
})

cy.reload()
cy.contains("MiniKube").click()

cy.wait('@postresult',{ responseTimeout: 35000 }).then((interception) => {
  assert.isNotNull(interception.response.body, '{code: 201, message: "Vote saved sucessfully"}')
})
cy.reload()
cy.contains("Roost").click()

cy.wait('@postresult',{ responseTimeout: 35000 }).then((interception) => {
  assert.isNotNull(interception.response.body, '{code: 201, message: "Vote saved sucessfully"}')
})
cy.reload()
cy.contains("K3D").click()

cy.wait('@postresult',{ responseTimeout: 35000 }).then((interception) => {
  assert.isNotNull(interception.response.body, '{code: 201, message: "Vote saved sucessfully"}')
})

cy.visit('http://roost-controlplane:30030/voter/result')
cy.contains('Roost')
cy.contains('Docker')
cy.contains('MiniKube')
cy.contains('K3D')
  })
})
