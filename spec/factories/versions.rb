# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :version do
    sequence(:version_code) {|n| n}
    sequence(:version_name) {|n| "version#{n}"}
    description "MyText"
    user_id 1

    factory :version_code_8_version do
      version_code 8
    end

    factory :version_code_9_version do
      version_code 9
    end

    factory :version_code_10_version do
      version_code 10
    end

    factory :others_user_version do
      user_id 999
      application_id 99
    end

  end
end
