require 'spec_helper'

describe ContentfulRails::Engine do
  describe "subscribe_to_webhook_events" do
    describe "unpublish" do
      let(:event) { "Contentful.Entry.unpublish" }
      let(:params) { { sys: { id: "fake_content_id" } } }
      let(:cache_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

      before do
        allow_any_instance_of(ActionController::Base).to receive(:cache_store).and_return(cache_store)
        allow_any_instance_of(ActionController::Base).to receive(:cache_configured?).and_return(true)
      end

      subject { ActiveSupport::Notifications.instrument(event, params) }

      it "passes delete_matched to the store" do
        expect(cache_store).to receive(:delete_matched)
        subject
      end

      context "MemCacheStore" do
        let(:cache_store) { ActiveSupport::Cache.lookup_store(:mem_cache_store) }

        it "doesn't raise error" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end
end
