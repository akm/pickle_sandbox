Feature: Display products
  In order to to purchase the right product
  A customer
  wants to browse products and see detailed infomation

  Scenario: Show product
    Given a product exists with name: "Milk", price: "2.99"
    When I go to the show page for that product
    Then I should see "Milk" within "h1"
    And I should see "2.99"

  Scenario: List products
    Given the following products exist
      | name   | price |
      | Milk   | 2.99  |
      | Puzzle | 8.99  |
    When I go to path "/products"
    Then I should see products table
      | Milk   | $2.99  |
      | Puzzle | $8.99  |
