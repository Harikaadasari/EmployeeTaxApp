module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :set_employee, only: [:tax_deduction]

      def create
        employee = Employee.new(employee_params)
        phone_numbers_array = employee_params[:phone_numbers].split(',').map(&:strip)

        puts phone_numbers_array.inspect

        if employee.valid? && employee.save
          render json: { message: "Employee details stored successfully" }, status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end


      def index
        employees = Employee.all
        render json: employees
      end

      def tax_deduction
        return render json: { error: "Employee not found" }, status: :not_found unless @employee

        yearly_salary = @employee.salary * months_employed / 12
        tax = calculate_tax(yearly_salary)
        cess = yearly_salary > 2500000 ? yearly_salary * 0.02 : 0

        tax_data = {
          employee_code: @employee.employee_id,
          first_name: @employee.first_name,
          last_name: @employee.last_name,
          email: @employee.email,  # Include email in the response
          phone_numbers: @employee.phone_numbers,  # Include phone numbers in the response
          doj: @employee.doj,  # Include date of joining in the response
          salary: @employee.salary,  # Include salary in the response
          yearly_salary: yearly_salary,
          tax_amount: tax,
          cess_amount: cess
        }

        render json: tax_data
      end

      def update
        employee = Employee.find_by(id: params[:id])

        if employee.update(employee_params)
          render json: { message: "Employee details updated successfully" }
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        employee = Employee.find_by(id: params[:id])

        if employee.destroy
          render json: { message: "Employee deleted successfully" }
        else
          render json: { error: "Unable to delete employee" }, status: :unprocessable_entity
        end
      end

      private

      def employee_params
        params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :phone_numbers, :doj, :salary)
      end

      def set_employee
          @employee = Employee.find_by(id: params[:employee_id])
      end



      def months_employed
        ((Date.today - @employee.doj).to_i / 30.0).ceil
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
  end
end
