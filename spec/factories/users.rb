# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'example@example.com'
    password 'changeme'
    password_confirmation 'changeme'
    application {
      Array(5..10).sample.times.map do
        FactoryGirl.create(:application)
      end
    }

    factory :other_user do
      email 'specialcyci@gmail.com'
    end

    factory :has_version_model_user do
      application {
        Array(5..10).sample.times.map do
          FactoryGirl.create(:has_versions_application)
        end
      } 
    end
  end
end
