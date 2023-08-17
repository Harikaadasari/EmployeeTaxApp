# app/models/employee.rb
class Employee < ApplicationRecord
  # Validations
  validates :employee_id, :first_name, :last_name, :email, :doj, :salary, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_phone_numbers
  validates :salary, numericality: { greater_than: 0 }

  def validate_phone_numbers
    phone_numbers_array = phone_numbers.split(',').map(&:strip)
    phone_numbers_array.each do |phone_number|
      unless /\A\d{10}\z/.match?(phone_number)
        errors.add(:phone_numbers, "#{phone_number} is an invalid phone number format")
      end
    end
  end



  def months_employed
    ((Date.today - doj).to_i / 30.0).ceil
  end

  def calculate_tax(yearly_salary)
    case yearly_salary
    when 0..250000
      0
    when 250001..500000
      (yearly_salary - 250000) * 0.05
    when 500001..1000000
      12500 + (yearly_salary - 500000) * 0.10
    else
      112500 + (yearly_salary - 1000000) * 0.20
    end
  end
end
