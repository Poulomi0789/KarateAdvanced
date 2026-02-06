Feature: API Chaining Demo

  Background:
    * url karate.get('baseUrl')

  Scenario: Create a post and then add a comment to that specific post
    # 1. Create the Post (POST)
    Given path 'posts'
    And request { title: 'Karate Chaining', body: 'Testing is easy', userId: 1 }
    When method POST
    Then status 201
    # Validate response schema
    And match response == read('classpath:schemas/post-schema.json')
    * def newPostId = response.id
    * print 'Created Post ID:', newPostId

    # 2. Get comments for the new post (GET)
    Given path 'comments'
    And param postId = newPostId
    When method GET
    Then status 200
    # Validate each comment matches schema
    And match each response[*] == read('classpath:schemas/comment-schema.json')
    * print 'Chained comments for post:', response
