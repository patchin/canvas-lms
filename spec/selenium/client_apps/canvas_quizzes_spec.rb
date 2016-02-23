require_relative "../common"

describe "canvas_quizzes" do
  include_context "in-process server selenium tests"

  before do
    Account.default.tap do |account|
      account.enable_feature! :quiz_stats
      account.save!
    end

    quiz_with_graded_submission([
      {:question_data => {:name => 'question 1', :points_possible => 1, 'question_type' => 'true_false_question'}},
      {:question_data => {:name => 'question 2', :points_possible => 1, 'question_type' => 'true_false_question'}}
    ])

    course_with_teacher_logged_in(:active_all => true, :course => @course)
  end

  describe 'statistics app' do
    it 'should mount' do
      get "/courses/#{@course.id}/quizzes/#{@quiz.id}/statistics"
      wait = Selenium::WebDriver::Wait.new(timeout: 5)
      wait.until { f("#summary-statistics").present? }
      expect(f("#summary-statistics")).to include_text('Average Score')
    end
  end

  describe 'events app' do
    it 'should mount' do
      Account.default.enable_feature!(:quiz_log_auditing)
      sub = @quiz.quiz_submissions.first
      get "/courses/#{@course.id}/quizzes/#{@quiz.id}/submissions/#{sub.id}/log"
      wait = Selenium::WebDriver::Wait.new(timeout: 5)
      wait.until { f("#ic-EventStream").present? }
      expect(f("#ic-EventStream")).to include_text('Action Log')
    end
  end

end
