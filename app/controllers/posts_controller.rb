class PostsController < ApplicationController
    
    before_action :baria_post, only: [:destroy]
    
    def create
      @new_post = Post.new(post_params)
      @new_post.user_id = current_user.id
      tag_list = tag_params[:names].split(/[[:blank:]]+/).select(&:present?)
      if (tag_list.length > 0) && @new_post.save
        @new_post.save_tags(tag_list)
        redirect_to post_path(@new_post.id)
      else
        redirect_to request.referer
        flash[:"alert-danger"] = "タグの入力は必須です"
      end
    end
    
    def index
      @posts = Post.joins(:post_tags).where(post_tags: {tag_id: current_user.tags.ids}).order(created_at: :desc).uniq
      @tag_post_ranks = Tag.find(PostTag.group(:tag_id).order('count(tag_id)desc').limit(5).pluck(:tag_id))
    end
    
    def show
      @post = Post.find(params[:id])
      @comment = Comment.new
      @tags = @post.tags
    end
    
    def tag
      @posts = Tag.find_by(name: params[:tag]).posts.order(created_at: :desc)
      @tag = Tag.find_by(name: params[:tag])
    end
    
    def destroy
      @post = Post.find(params[:id])
      @post.destroy
      redirect_to home_path
    end
    
    private
    
    def post_params
      params.require(:post).permit(:body, :image, :tagbody)
    end
    
    def tag_params
      params.require(:post).permit(:names)
    end
    
    def baria_post
      unless Post.find(public[:id]).user.id.to_i == current_user.id
        flash[:notice] = "権限がありません"
        redirect_to home_path
      end
    end
end