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
    respond_to do |format|
      if @question
        format.json { render :json => {:redirectURL => edit_node_path(@node), :id => @question.id} }
      else
        format.json { render :json => "There was a problem saving your question.", :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @node = Node.find(params[:node_id])
    @question = Question.find(params[:id])
  end

  def update
    @node = Node.find(params[:node_id])
    @question = Question.find params[:id]
    editor_data = ActiveSupport::JSON.decode(params[:question][:data])
    respond_to do |format|
      if @question.update_from_editor_data(editor_data, :node_id => params[:node_id])
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
    @question = Question.find params[:id]
    @node = Node.find params[:node_id]
    @question.destroy
    redirect_to edit_node_path(@node)
  end

  def submit
    node_id = params[:node_id].to_i
    if !current_user  # SHOULD WE REQUIRE USERS TO LOG IN TO SUBMIT AN ANSWER??
      flash[:error] = "You must be logged in to submit an answer!"
      redirect_to node_path(node_id) and return 
    end
    question_id = params[:question_id].to_i
    question = Question.find_by_id(question_id)
    if !question
      flash[:error] = "This question does not exist!"
      redirect_to node_path(node_id) and return
    end
    if !params[:answer]
      flash[:error] = "Please select an answer"
      redirect_to node_path(node_id) and return 
    end 
    submitted_answer = params[:answer].to_i    # index of submitted answer
    is_correct = question.grade(submitted_answer)
    
    submission = question.question_submissions.new
    submission.user_id = current_user.id
    submission.node_id = node_id
    # submission.question_id = question_id
    submission.student_answers = submitted_answer
    submission.correct = is_correct
    if !submission.save
      flash[:error] = "There was a problem with your submission, please try again"
      redirect_to node_path(node_id) and return
    elsif is_correct
      flash[:notice] = "Correct!"
      redirect_to node_path(node_id) and return
    else
      flash[:error] = "Incorrect!"
      redirect_to node_path(node_id) and return
    end    
  end

  def textile_to_html
    render :json => (RedCloth.new(params[:text]).to_html).to_json
  end

end
