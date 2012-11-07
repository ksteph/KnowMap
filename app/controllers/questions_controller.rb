class QuestionsController < ApplicationController
  #before_filter :require_user, :only => [:index, :destroy]

  def new
    @node = Node.find(params[:node_id])
    @question = @node.questions.new
  end

  def create
    @node = Node.find(params[:node_id])
    editor_data = ActiveSupport::JSON.decode(params[:question][:data])
    @question = Question.from_editor_data(editor_data, :node_id => params[:node_id])
    binding.pry
    respond_to do |format|
      if @question
        format.json { render :json => {:redirectURL => edit_node_path(@node), :id => @question.id} }
      else
        format.json { render :json => "There was a problem saving your question.", :status => :unprocessable_entity }
      end
    end
  end

  def show
    show_points = params[:show_points]
    show_delete = params[:show_delete]
    respond_to do |format|
      format.html do
        if request.xhr?
          render text: (render_cell :questions, :show, question: @question, user: current_user, show_points: show_points, show_stats: false, show_delete: show_delete)
        end
      end
      format.json { render :json => @question.json }
    end
  end

  def search
    key = params[:key] || ""
    @questions = Question.accessible_by(current_ability, :read).where('parent_id is NULL AND (lower(title) LIKE ? OR lower(text) LIKE ?)', "%#{key}%", "%#{key}%")
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def index

  end

  def destroy
    @question.destroy
    redirect_to course_questions_path
  end

  def submit
    # create a Question_Submission entry
    @node_id = params[:node_id].to_i
    @answer = params[:answer].to_i
    flash[:warning] = "QUESTION SUBMISSION ISN'T READY YET!"
    # redirect_to node_path(@node_id) and return
  end

end
