# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :application do
    sequence(:app_name) {|n| "app#{n}" }
    sequence(:package_name) {|n| "cn.scau.scautreasure#{n}" }
    description "MyText"

    factory :others_application do
      user_id 99999
    end

    factory :has_versions_application do
      version {
        Array(5..10).sample.times.map do
          FactoryGirl.create(:version)
        end
      } 
    end
  end
end
