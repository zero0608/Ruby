class Admin::EmployeesController < ApplicationController
	before_action :find_department, only: [:new]

  def new
    if current_user.user_group.hr_cru
      @employee = Employee.new
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    @employee = Employee.new(employee_params)
    @employee.unpaid_days = 0
    @employee.pto_remain = @employee.pto_days
    @employee.personal_remain = @employee.personal_days
    @employee.sick_remain = @employee.sick_days
    
    if @employee.save
      onboard_account = @employee.checklists.create(employee_id: @employee.id, description: "Account Access", list_type: "Onboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Affirm", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Avalara", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Cloudways", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Connect", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Gorgias", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Infinite", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Magento", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Microsoft Office", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Paybright", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Paypal", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Slack", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Stripe CA", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Stripe US", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Trello", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Xero", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)

      onboard_communications = @employee.checklists.create(employee_id: @employee.id, description: "Communications", list_type: "Onboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Add employee to teams sharepoint", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Add employee to communication channels", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Add employees to regular scheduled meetings", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Schedule intro meetings with department heads", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      
      onboard_documents = @employee.checklists.create(employee_id: @employee.id, description: "Documents and Enrolments", list_type: "Onboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Uploaded offer letter", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Setup employee payroll account", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Prepare health care documents (register user after 3 months probation)", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
      
      onboard_equipment = @employee.checklists.create(employee_id: @employee.id, description: "Equipment", list_type: "Onboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Setup employee with office fob", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_equipment.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Provide and setup employee with computer", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_equipment.id)

      offboard_account = @employee.checklists.create(employee_id: @employee.id, description: "Account Remove Access", list_type: "Offboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Affirm", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Avalara", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Cloudways", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Connect", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Gorgias", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Infinite", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Magento", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Microsoft Office", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Paybright", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Paypal", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Slack", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Stripe CA", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Stripe US", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Trello", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Xero", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)

      offboard_communications = @employee.checklists.create(employee_id: @employee.id, description: "Communications", list_type: "Offboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Remove employee from teams sharepoint", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Remove employee from communication channels", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Remove employees from regular scheduled meetings", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
      
      offboard_documents = @employee.checklists.create(employee_id: @employee.id, description: "Documents and Enrolments", list_type: "Offboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Uploaded exit letter", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_documents.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Unregister employee health care", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_documents.id)
      
      offboard_equipment = @employee.checklists.create(employee_id: @employee.id, description: "Equipment", list_type: "Offboarding", is_checked: false, is_default: true)
      @employee.checklists.create(employee_id: @employee.id, description: "Return office fob", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_equipment.id)
      @employee.checklists.create(employee_id: @employee.id, description: "Return computer and office equipment", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_equipment.id)

      Showroom.all.each do |showroom|
        @employee.showroom_manage_permissions.create(showroom_id: showroom.id)
      end

      redirect_to admin_departments_path, success: "Employee created successfully."
    else
      render 'new'
    end
  end  

  def edit
    if current_user.user_group.hr_cru
      @employee = Employee.find(params[:id])
      @department = @employee.department
      unless @employee.showroom_manage_permissions.present?
        Showroom.all.each do |showroom|
          @employee.showroom_manage_permissions.create(showroom_id: showroom.id)
        end
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def list
    if current_user.user_group.hr_cru
      @employee = Employee.find(params[:id])
      @department = @employee.department
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update(employee_params)
      redirect_to edit_admin_employee_path(@employee.id), success: "Employee updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    Employee.find_by(id: params[:id]).destroy
    redirect_to admin_departments_path
  end

  # For deleting attachments 
  def delete_upload
    @employee = Employee.find(params[:id])
    attachment = ActiveStorage::Attachment.find_by(id: params[:doc_id])
    attachment.purge if attachment.present?
    redirect_to edit_admin_employee_path(@employee.id)
  end

  def reset_checklist
    @employee = Employee.find(params[:id])
    @employee.checklists.where("list_group_id is NOT NULL").destroy_all
    @employee.checklists.destroy_all

    onboard_account = @employee.checklists.create(employee_id: @employee.id, description: "Account Access", list_type: "Onboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Affirm", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Avalara", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Cloudways", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Connect", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Gorgias", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Infinite", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Magento", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Microsoft Office", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Paybright", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Paypal", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Slack", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Stripe CA", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Stripe US", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Trello", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Xero", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)

    onboard_communications = @employee.checklists.create(employee_id: @employee.id, description: "Communications", list_type: "Onboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Add employee to teams sharepoint", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Add employee to communication channels", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Add employees to regular scheduled meetings", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Schedule intro meetings with department heads", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      
    onboard_documents = @employee.checklists.create(employee_id: @employee.id, description: "Documents and Enrolments", list_type: "Onboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Uploaded offer letter", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Setup employee payroll account", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Prepare health care documents (register user after 3 months probation)", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
      
    onboard_equipment = @employee.checklists.create(employee_id: @employee.id, description: "Equipment", list_type: "Onboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Setup employee with office fob", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_equipment.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Provide and setup employee with computer", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_equipment.id)

    offboard_account = @employee.checklists.create(employee_id: @employee.id, description: "Account Remove Access", list_type: "Offboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Affirm", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Avalara", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Cloudways", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Connect", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Gorgias", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Infinite", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Magento", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Microsoft Office", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Paybright", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Paypal", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Slack", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Stripe CA", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Stripe US", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Trello", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Xero", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)

    offboard_communications = @employee.checklists.create(employee_id: @employee.id, description: "Communications", list_type: "Offboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Remove employee from teams sharepoint", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Remove employee from communication channels", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Remove employees from regular scheduled meetings", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
      
    offboard_documents = @employee.checklists.create(employee_id: @employee.id, description: "Documents and Enrolments", list_type: "Offboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Uploaded exit letter", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_documents.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Unregister employee health care", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_documents.id)
      
    offboard_equipment = @employee.checklists.create(employee_id: @employee.id, description: "Equipment", list_type: "Offboarding", is_checked: false, is_default: true)
    @employee.checklists.create(employee_id: @employee.id, description: "Return office fob", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_equipment.id)
    @employee.checklists.create(employee_id: @employee.id, description: "Return computer and office equipment", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_equipment.id)
  
    redirect_to list_admin_employee_path(@employee.id)
  end

  def reset_all_checklists
    Employee.all.each do |employee|
      employee.checklists.where("list_group_id is NOT NULL").destroy_all
      employee.checklists.destroy_all

      onboard_account = employee.checklists.create(employee_id: employee.id, description: "Account Access", list_type: "Onboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Affirm", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Avalara", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Cloudways", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Connect", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Gorgias", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Infinite", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Magento", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Microsoft Office", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Paybright", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Paypal", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Slack", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Stripe CA", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Stripe US", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Trello", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Xero", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_account.id)

      onboard_communications = employee.checklists.create(employee_id: employee.id, description: "Communications", list_type: "Onboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Add employee to teams sharepoint", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      employee.checklists.create(employee_id: employee.id, description: "Add employee to communication channels", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      employee.checklists.create(employee_id: employee.id, description: "Add employees to regular scheduled meetings", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
      employee.checklists.create(employee_id: employee.id, description: "Schedule intro meetings with department heads", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_communications.id)
        
      onboard_documents = employee.checklists.create(employee_id: employee.id, description: "Documents and Enrolments", list_type: "Onboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Uploaded offer letter", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
      employee.checklists.create(employee_id: employee.id, description: "Setup employee payroll account", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
      employee.checklists.create(employee_id: employee.id, description: "Prepare health care documents (register user after 3 months probation)", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_documents.id)
        
      onboard_equipment = employee.checklists.create(employee_id: employee.id, description: "Equipment", list_type: "Onboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Setup employee with office fob", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_equipment.id)
      employee.checklists.create(employee_id: employee.id, description: "Provide and setup employee with computer", list_type: "Onboarding", is_checked: false, is_default: true, list_group_id: onboard_equipment.id)

      offboard_account = employee.checklists.create(employee_id: employee.id, description: "Account Remove Access", list_type: "Offboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Affirm", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Avalara", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Cloudways", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Connect", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Gorgias", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Infinite", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Magento", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Microsoft Office", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Paybright", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Paypal", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Slack", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Stripe CA", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Stripe US", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Trello", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)
      employee.checklists.create(employee_id: employee.id, description: "Xero", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_account.id)

      offboard_communications = employee.checklists.create(employee_id: employee.id, description: "Communications", list_type: "Offboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Remove employee from teams sharepoint", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
      employee.checklists.create(employee_id: employee.id, description: "Remove employee from communication channels", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
      employee.checklists.create(employee_id: employee.id, description: "Remove employees from regular scheduled meetings", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_communications.id)
        
      offboard_documents = employee.checklists.create(employee_id: employee.id, description: "Documents and Enrolments", list_type: "Offboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Uploaded exit letter", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_documents.id)
      employee.checklists.create(employee_id: employee.id, description: "Unregister employee health care", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_documents.id)
        
      offboard_equipment = employee.checklists.create(employee_id: employee.id, description: "Equipment", list_type: "Offboarding", is_checked: false, is_default: true)
      employee.checklists.create(employee_id: employee.id, description: "Return office fob", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_equipment.id)
      employee.checklists.create(employee_id: employee.id, description: "Return computer and office equipment", list_type: "Offboarding", is_checked: false, is_default: true, list_group_id: offboard_equipment.id)
    end
    redirect_to admin_departments_path
  end

  private

  def find_department
    @department = Department.find_by(id: params[:department_id])
  end

  def employee_params
    params.require(:employee).permit(:department_id, :position_id, :manager_id, :first_name, :last_name, :email, :phone, :dob, :employment_type, :health_number, :emergency_contact, :emergency_number, :work_mon, :work_tue, :work_wed, :work_thu, :work_fri, :work_sat, :work_sun, :start_date, :exit_date, :voluntary_exit, :salary, :bonus, :pto_days, :personal_days, :sick_days, :unpaid_days, :pto_remain, :personal_remain, :sick_remain, :hr_notes, :pay_type, :is_director, :is_billing, :sales_permission, :showroom_id, documents: [], showroom_manage_permissions_attributes: [ :id, :permission ], checklists_attributes: [ :id, :employee_id, :description, :list_type, :is_checked, :is_default ])
  end
end