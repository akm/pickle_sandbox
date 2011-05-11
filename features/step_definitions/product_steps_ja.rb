# -*- coding: utf-8 -*-
Then /^以下の商品テーブルが表示されること$/ do |expected_products_table|
  Then %{I should see products table}, expected_products_table
end
