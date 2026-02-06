Feature: Update Post Demo (PUT)

  Background:
    # Base URL from config
    * url karate.get('baseUrl')

  Scenario: Update an existing post
    # 1. Create a new post first
    Given path 'posts'
    And request { title: 'Original Title', body: 'Original body', userId: 1 }
    When method POST
    Then status 201
    * def postId = response.id
    * print 'Created Post ID:', postId

    # 2. Update the post with a PUT request
    Given path 'posts', postId
    And request { id: postId, title: 'Updated Title', body: 'Updated body', userId: 1 }
    When method PUT
    Then status 200

    # Validate response schema
    * def postSchema = read('classpath:schemas/post-schema.json')
    And match response == postSchema

    # 3. Get the post to verify update
    Given path 'posts', postId
    When method GET
    Then status 200
    And match response.title == 'Updated Title'
    And match response.body == 'Updated body'
    * print 'Post successfully updated:', response
