FactoryBot.define do
  factory :tea do
    title { "MyString" }
    description { "MyText" }
    temperature { 1 }
    brew_time { 1 }
  end
end
