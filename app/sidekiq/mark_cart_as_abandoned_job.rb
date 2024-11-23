class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    carts_to_mark_as_abandoned = Cart.where('updated_at < ?', 3.hours.ago)
                                      .where(state: 'active')

    carts_to_mark_as_abandoned.find_each do |cart|
      cart.update(state: 'abandoned')
    end

    carts_to_remove = Cart.where('updated_at < ?', 7.days.ago)
                          .where(state: 'abandoned')

    carts_to_remove.destroy_all
  end
end
