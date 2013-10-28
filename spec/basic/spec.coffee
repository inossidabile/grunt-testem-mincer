describe 'Environment', ->

  it 'loads vendored js', ->
    expect(window.hello).toBeDefined()
    expect(hello? 'Boris').toEqual 'Hello, Boris'

  it 'loads vendored js with problematic name', ->
    expect(window.hello).toBeDefined()
    expect(screw? 'Boris').toEqual 'Screw, Boris'

  it 'loads helper', ->
    expect(window.helper).toBeDefined()
    expect(helper?()).toEqual 'helper'