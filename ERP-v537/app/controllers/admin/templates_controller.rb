class Admin::TemplatesController < ApplicationController
  def index
    if current_user.user_group.hr_view
      @templates = Template.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    if current_user.user_group.hr_cru
      @templates = Template.all
      @template = Template.new
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    if current_user.user_group.hr_cru
      @template = Template.new(template_params)
      if @template.save
        redirect_to edit_admin_template_path(id: @template.id), success: "Template created successfully."
      else
        render 'new'
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def edit
    if current_user.user_group.hr_cru
      @templates = Template.all
      @template = Template.find(params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @template = Template.find(params[:id])
    if @template.update(template_params)
      redirect_to edit_admin_template_path(id: @template.id), success: "Template updated successfully."
    else
      render 'edit'
    end
  end
  
  def pdf
  end

  private

  def template_params
    params.require(:template).permit(:title, :content)
  end
end